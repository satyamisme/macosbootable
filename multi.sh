#!/bin/bash

# List disks to choose from
diskutil list
echo ""
read -p "Enter the disk identifier to partition: " disk

# Specify the partition sizes and names in GB
sizes=(10g 10g 10g 10g 10g)
names=(Partition1 Partition2 Partition3 Partition4 Data)

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
