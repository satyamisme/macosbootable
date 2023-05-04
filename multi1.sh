#!/bin/bash

# List disks to choose from
diskutil list
echo ""
read -p "Enter the disk identifier to partition: " disk

# Specify the partition sizes and names in GB
sizes=(6g 6g 7g 9g 14g 15g 15g 30g 20g)
names=(1 2 3 4 5 6 7 8 Data)

# Calculate total size of partitions
total_size=0
for element in "${sizes[@]}"; do
  total_size=$(($total_size + $(echo ${element%g})))
done

# Check if total size of partitions is more than disk size and adjust last partition size
disk_size=$(diskutil info /dev/${disk} | awk '/Size:/ {print $2$3}')
if [[ $(echo ${total_size}g) > $(echo ${disk_size}) ]]; then
  last_size=$((${disk_size%.*} - ($total_size - ${sizes[-1]%g})))
  sizes[-1]=${last_size}g
fi

# Partition the disk
partitions=""
for ((i=0; i<${#sizes[@]}; i++)); do
  partitions="${partitions} JHFS+ ${names[$i]} ${sizes[$i]}"
done
echo "Partitioning /dev/${disk} with sizes ${sizes[*]} and names ${names[*]}"
sudo diskutil partitionDisk /dev/${disk} GPT${partitions}

# Format the partitions
diskutil list | grep /dev/${disk}
for ((i=0; i<${#sizes[@]}; i++)); do
  part_name="${names[$i]}"
  part_id=$(diskutil list | awk -v disk=${disk} -v part_num=${i} '$0 ~ disk {for (i=1; i<=NF; i++) if (index($i, disk "s" part_num) > 0) {print $i; exit}}')
  echo "Formatting ${part_name} (${part_id}) on /dev/${disk}"
  sudo diskutil eraseVolume JHFS+ "${part_name}" ${part_id}
done

echo "Formatting complete"
