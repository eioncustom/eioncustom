#!/bin/bash
#You must have Mellanox OFED and Mellanox/Nvidia Networking Interface Cards Present in you machine for this to work...
show_debug=false

# Process command-line debug arguments
# Use -d to invoke showing the output of ibdev2netdev prior to showing the PCI Bus Link Widths
while getopts "d" opt; do
  case $opt in
    d)
      show_debug=true
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      exit 1
      ;;
  esac
done

# Use ibdev2netdev -v to obtain the PCI bus addresses
output=$(ibdev2netdev -v)
pci_addresses=($(echo "$output" | grep "0000" | awk '{print $1}'))

# Check if any PCI addresses were found
if [ ${#pci_addresses[@]} -eq 0 ]; then
  echo "No PCI bus addresses found."
else
  if [ "$show_debug" = true ]; then
    echo "We have found the following Mellanox Devices with ibdev2netdev:"
    echo "$output"
    echo
    sleep 2
  fi

  echo "Checking PCI Bus Addresses found..."
  sleep 3

  # Loop through each PCI address
  for pci_address in "${pci_addresses[@]}"; do
    # Run lspci -vv -s with the current PCI address
    lspci_output=$(lspci -vv -s "$pci_address" | grep -P "[0-9a-f]{2}:[0-9a-f]{2}\.[0-9a-f]|LnkSta:"|grep -v '16GT/s, Width x16'|grep -v Mell|cut -d " " -f 2,3,4,5,6)
    echo "$pci_address state is currently: $lspci_output"
  done
fi
