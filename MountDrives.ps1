
###########################################################################
########## Author  : Benjamin F. 
##########
########## Exemple : 	1) 	Mount-Disk -Letter Z: -Ip SERVEUR!PORT -Path PATH -User USER -Pass PASSWORD -Nickname "MY FILE SERVER"
##########  			    2) 	Create a shortcut in "C:\Users\<CurrentUser>\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup"
##########	   			    Run in : "C:\Windows\System32\WindowsPowerShell\v1.0\powershell" 
##########			   	    Target : "C:\Users\<CurrentUser>\AppData\Roaming\Microsoft\Windows\MountDrives.ps1" (This script)
##########
########## Exemple : 	Mount-Disk -Letter Z: -Ip myserveur.eu!22 -Path myfolder -User jhon -Pass jhonissmart -Nickname "My file server"
##########
########## Notes   : 	/!\ SSHFS service as a simple mind (Read/Write/Execute)
########## 				    Don't try to set up through Windows Explorer features ! Bugs ? Just reboot.
###########################################################################
# Monte un disque reseau en SSH | Note: ip="ip!port"
function Mount-Disk { 
param ([string]$Letter,[string]$Ip,[string]$P,[string]$Path,[string]$User,[string]$Pass,[string]$Nickname)
	If (! (Test-Path $letter)){ 
		If ($path) { $rlpath = $path ; $path1 = "\" + $rlpath; $path2 = "#" + $rlpath }
		net use $letter "\\sshfs\$user@$ip$path1" /user:"$user" "$pass" /persistent:yes
		Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\MountPoints2\##sshfs#$user@$ip$path2" -Name "_LabelFromReg" -Value "$nickname"		
	}
}
# Installer SSHFS via Choco
function Install-Sshfs { 
	If (! ((Get-ExecutionPolicy) -eq 'Unrestricted')) {
		Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser -force
	}If (! (choco -v)) {
		Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
		choco install -y sshfs
	}
}
# Deployer le script au demarrage (seulement si la persistance echoue)
function Deploy-Startup-Script { 
		$scriptpath = "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Windows\MountDrives.ps1"
		$shortcutpath = "C:\Users\$env:UserName\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Startup\MountDrives.lnk"
		If (! [System.IO.File]::Exists($scriptpath)){ Copy-Item $MyInvocation.PSCommandPath -Destination $scriptpath }
		If (! [System.IO.File]::Exists($shortcutpath)){
			$WScriptShell = New-Object -ComObject WScript.Shell
			$Shortcut = $WScriptShell.CreateShortcut($shortcutpath)
			$Shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
			$Shortcut.Arguments = "-file $scriptpath" 
			$Shortcut.Save()
		}
}
###########################################################################

########## Installer SSHFS
Install-Sshfs

########## Monter les disques
Mount-Disk -Letter Z: -Ip 192.168.1.1!22 -Path myfolder -User jhon -Pass jhonissmart -Nickname "My file server"
# Manual
# net use DRIVE_LETTER: "\\sshfs\USER@SERVER_IP" /user:"USER" "PASSWORD" /persistent:yes

########## Deployer le script au demarrage
# Attention aux droits du fichier, limiter l'acces READ à root uniquement, il contient le password !
# Deploy-Startup-Script
###########################################################################
