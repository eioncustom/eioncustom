# Define the start and end numbers for the hostname
$startNumber = 1
$endNumber = 3016

# Loop through the range of numbers
for ($i = $startNumber; $i -le $endNumber; $i++) {
    # Construct the hostname with leading zeros
    $hostname = "hostname" + $i.ToString("D4")

    # Execute the SSH command using SSH
    # Assuming you have an SSH client like OpenSSH installed and configured in PowerShell
    ssh -o StrictHostKeyChecking=no ubuntu@$hostname 'sudo apt-get update && export DEBIAN_FRONTEND=noninteractive && export APT_LISTCHANGES_FRONTEND=none && sudo NEEDRESTART_MODE=a apt --assume-yes -o Dpkg::Options::="--force-confold" --assume-yes -o Dpkg::Options::="--force-confdef" -fuyq full-upgrade && sudo reboot now'
    
    # Optional: wait a bit before the next iteration to avoid overloading the servers (Not Always Needed)
    Start-Sleep -Seconds 5
}
