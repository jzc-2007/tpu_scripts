import gspread
from google.oauth2.service_account import Credentials
import logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s [%(levelname)s] %(message)s')

from datetime import datetime
import pytz
from ka_checker import check_ka
import signal

def signal_handler(sig, frame):
    print('Sending final logs to the sheet, please do not interrupt...')

class SheetManager:
    def __init__(self, path_to_secret = "./secret.json", sheet_id = "1MFtgLx7uzBFdiPxrIqck00ilrSslZU2w2jRwriVpKMw", sheet_name = "ka[experimental]"):
        self.path_to_secret = path_to_secret
        self.sheet_id = sheet_id
        self.sheet_name = sheet_name
        self.connect()
        self.logs = []
    
    def __enter__(self):
        self.connect()
        self.sanity()
        self.write_start()
        return self
    
    def __exit__(self, exc_type, exc_value, exc_traceback):
        self.write_end(exc_type, exc_value, exc_traceback)
        
    def log(self, msg):
        logging.info(msg)
        self.logs.append(msg)

    def connect(self):
        SERVICE_ACCOUNT_FILE = self.path_to_secret
        SCOPES = ["https://www.googleapis.com/auth/spreadsheets"]
        creds = Credentials.from_service_account_file(SERVICE_ACCOUNT_FILE, scopes=SCOPES)
        client = gspread.authorize(creds)
        spreadsheet = client.open_by_key(self.sheet_id)
        self.worksheet = spreadsheet.worksheet(self.sheet_name)

    def sanity(self):
        worksheet = self.worksheet
        assert all([worksheet.acell(cell).value == "SANITY" for cell in ["A6","J6","A25","J25"]]), "Sanity check failed: {}".format([worksheet.acell(cell).value for cell in ["A6","J6","A25","J25"]])
        self.log("Sanity check passed")
        
    def get_times(self):
        start_time = datetime.now()
        # convert to EST time
        start_time_est = start_time.astimezone(pytz.timezone('US/Eastern'))
        start_time_chn = start_time.astimezone(pytz.timezone('Asia/Shanghai'))
        est_time_str = start_time_est.strftime('%Y-%m-%d %H:%M:%S')
        chn_time_str = start_time_chn.strftime('%Y-%m-%d %H:%M:%S')
        return est_time_str, chn_time_str
    
    def modify_cell(self, cell_id, value):
        self.worksheet.update([[value]], cell_id)
    
    def write_start(self):
        est_time_str, chn_time_str = self.get_times()
        self.log("Script start at: EST {}, CST {}".format(est_time_str, chn_time_str))
        self.modify_cell("B5", f"{est_time_str} EST;\n{chn_time_str} CST")
        self.worksheet.format("A5", {"backgroundColor": {"red": 1.0, "green": 1.0, "blue": 1.0}})
        self.modify_cell("A5", "SCIRPT RUNNING")
        self.modify_cell("C5", "")
        self.modify_cell("D5", "")
        
    def write_end(self, exc_type, exc_value, exc_traceback):
        signal.signal(signal.SIGINT, signal_handler)
        success = (exc_type is None)
        est_time_str, chn_time_str = self.get_times()
        self.log("Script end at: EST {}, CST {}".format(est_time_str, chn_time_str))
        self.modify_cell("C5", f"{est_time_str} EST;\n{chn_time_str} CST")
        self.log("Success? {}".format(success))
        if not success:
            self.log("Error info: {}\n, {}\n".format(exc_type, exc_value))
        self.modify_cell("A5", "Success" if success else "Failed")
        # change font color; use bold font
        color = (0.0, 1.0, 0.0) if success else (1.0, 0.0, 0.0)
        self.worksheet.format("A5", {"backgroundColor": {"red": color[0], "green": color[1], "blue": color[2]}, "textFormat": {"bold": True}})
        self.modify_cell("D5", "\n".join(self.logs))
        if not success:
            # raise
            raise exc_type(exc_value)
    
    def check_ka(self):
        all_to_check = [
            "v3-32-1", "v3-32-11", "v3-32-12", "v3-32-13", "v2-32-1", "v2-32-2", "v2-32-3", "v2-32-4", "v2-32-5", "v2-32-6", "v2-32-7", "v2-32-preemptible-1", "v2-32-preemptible-2", "v3-32-preemptible-1"
        ]
        all_to_check = ['kmh-tpuvm-' + ka for ka in all_to_check]
        for idx, ka in enumerate(all_to_check):
            self.log(f"Checking {ka}")
            result = check_ka(ka)
            self.log(f"Result: {result}")
            row_num = idx + 9
            
            status_to_write = self.worksheet.acell(f"D{row_num}").value
            user_to_write = self.worksheet.acell(f"E{row_num}").value
            desc_to_write = self.worksheet.acell(f"F{row_num}").value
            self.log(f"Last status: {status_to_write}, user: {user_to_write}, desc: {desc_to_write}")
            script_to_write = ""
            
            # fix invalid cell
            if status_to_write == "running":
                if user_to_write in ["闲的", "UNKNOWN"]:
                    # unknown user uses this card
                    script_to_write += "[Invalid cell] The ka is running but the user is unknown! "
                    user_to_write = "UNKNOWN"
            elif status_to_write == "闲的":
                if user_to_write not in ["闲的", "UNKNOWN"]:
                    # this is likely that the person forget to set the status to running/reserved
                    script_to_write += "[Invalid cell] The status used to not be 'running', we believe this is a mistake. "
                    status_to_write = "reserved"
                elif user_to_write == "UNKNOWN":
                    # useless
                    status_to_write = "闲的"
            elif status_to_write == "reserved":
                if user_to_write in ["闲的", "UNKNOWN"]:
                    # completely invalid
                    script_to_write += "[Invalid cell] The ka is reserved but the user is unknown! "
                    user_to_write = "闲的"
                    status_to_write = "闲的"
                    
            # now we can assume only following possible combinations:
            # 1. status: running, user: xxx (normal)
            # 2. status: running, user: UNKNOWN (unknown user)
            # 3. status: 闲的, user: 闲的 (normal)
            # 4. status: reserved, user: xxx (normal)
            
            # update using the script result
            if result == "internal error":
                script_to_write += "[Script] The shell script failed to run"
            elif result in ["preeempted", "env broken"]:
                # The ka must NOT be running. The user may not know this.
                if status_to_write == "running":
                    script_to_write += f"[Script] The run by user {user_to_write} is done or failed, as the ka is now {result}. "
                    status_to_write = "闲的"
                    user_to_write = "闲的"
                script_to_write = f"[Script] The ka is now {result}. " + script_to_write
            elif result == "xian":
                # the run is finished
                if status_to_write == "running":
                    if user_to_write != "UNKNOWN":
                        status_to_write = "reserved"
                        script_to_write += "[Script] The run is finished, switch status to reserved. "
                    else:
                        script_to_write += "[Script] The run is finished, and the user is unknown. "
            elif result == "running":
                if status_to_write == "闲的":
                    # the user may not know the status
                    script_to_write += "[Script] The ka is running, but no one knows! "
                    status_to_write = "running"
                    user_to_write = "UNKNOWN"
                elif status_to_write == "reserved":
                    # the run is still running
                    status_to_write = "running"
                    script_to_write += "[Script] The reserved card is running. "                    
            else:
                raise NotImplementedError("Invalid result: {}".format(result))
            
            # col: D: status, E: user, F: desc, G: script log
            self.worksheet.update([[status_to_write, user_to_write,desc_to_write, script_to_write]], f'D{row_num}:H{row_num+1}')

if __name__ == '__main__':
    with SheetManager() as sm:
        sm.check_ka()