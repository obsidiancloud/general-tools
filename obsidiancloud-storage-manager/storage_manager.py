#!/usr/bin/env python3
"""
Obsidian Cloud - Storage Manager
Production-grade disk management utility for Linux systems
"""

import os
import sys
import subprocess
import json
import argparse
import re
from datetime import datetime
from typing import Dict, List, Optional, Tuple
from dataclasses import dataclass
from enum import Enum
import shutil

# Color codes
class Color:
    HEADER = '\033[95m'
    OKBLUE = '\033[94m'
    OKCYAN = '\033[96m'
    OKGREEN = '\033[92m'
    WARNING = '\033[93m'
    FAIL = '\033[91m'
    ENDC = '\033[0m'
    BOLD = '\033[1m'

class OperationRisk(Enum):
    SAFE = "safe"
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"

@dataclass
class DiskInfo:
    name: str
    size: str
    type: str
    mountpoint: Optional[str]
    fstype: Optional[str]
    uuid: Optional[str]
    label: Optional[str]
    used: Optional[str] = None
    avail: Optional[str] = None
    use_percent: Optional[str] = None

class StorageManager:
    def __init__(self):
        self.backup_dir = "/var/backups/storage-manager"
        self.ensure_backup_dir()
    
    def ensure_backup_dir(self):
        try:
            os.makedirs(self.backup_dir, exist_ok=True)
        except PermissionError:
            self.backup_dir = os.path.expanduser("~/.storage-manager-backups")
            os.makedirs(self.backup_dir, exist_ok=True)
    
    def print_banner(self):
        banner = f"""{Color.OKCYAN}
╔═══════════════════════════════════════════════════════════════════════════╗
║                                                                           ║
║   ██████╗ ██████╗ ███████╗██╗██████╗ ██╗ █████╗ ███╗   ██╗               ║
║  ██╔═══██╗██╔══██╗██╔════╝██║██╔══██╗██║██╔══██╗████╗  ██║               ║
║  ██║   ██║██████╔╝███████╗██║██║  ██║██║███████║██╔██╗ ██║               ║
║  ██║   ██║██╔══██╗╚════██║██║██║  ██║██║██╔══██║██║╚██╗██║               ║
║  ╚██████╔╝██████╔╝███████║██║██████╔╝██║██║  ██║██║ ╚████║               ║
║   ╚═════╝ ╚═════╝ ╚══════╝╚═╝╚═════╝ ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝               ║
║                                                                           ║
║    ██████╗██╗      ██████╗ ██╗   ██╗██████╗                              ║
║   ██╔════╝██║     ██╔═══██╗██║   ██║██╔══██╗                             ║
║   ██║     ██║     ██║   ██║██║   ██║██║  ██║                             ║
║   ██║     ██║     ██║   ██║██║   ██║██║  ██║                             ║
║   ╚██████╗███████╗╚██████╔╝╚██████╔╝██████╔╝                             ║
║    ╚═════╝╚══════╝ ╚═════╝  ╚═════╝ ╚═════╝                              ║
║                                                                           ║
║                      STORAGE MANAGER v1.0.0                               ║
║                   Production-Grade Disk Management                        ║
║                                                                           ║
╚═══════════════════════════════════════════════════════════════════════════╝
{Color.ENDC}"""
        print(banner)
    
    def check_root_privileges(self) -> bool:
        return os.geteuid() == 0
    
    def run_command(self, cmd: List[str], require_root: bool = False, 
                   capture_output: bool = True) -> Tuple[int, str, str]:
        if require_root and not self.check_root_privileges():
            return (1, "", "Root privileges required for this operation")
        
        try:
            result = subprocess.run(cmd, capture_output=capture_output, text=True, check=False)
            return (result.returncode, result.stdout, result.stderr)
        except FileNotFoundError:
            return (127, "", f"Command not found: {cmd[0]}")
        except Exception as e:
            return (1, "", f"Error executing command: {str(e)}")
    
    def get_disk_info(self) -> List[DiskInfo]:
        exit_code, output, error = self.run_command(
            ['lsblk', '-J', '-o', 'NAME,SIZE,TYPE,MOUNTPOINT,FSTYPE,UUID,LABEL']
        )
        
        if exit_code != 0:
            print(f"{Color.FAIL}Error getting disk info: {error}{Color.ENDC}")
            return []
        
        try:
            data = json.loads(output)
            disks = []
            
            for device in data.get('blockdevices', []):
                disk = DiskInfo(
                    name=device.get('name', ''),
                    size=device.get('size', ''),
                    type=device.get('type', ''),
                    mountpoint=device.get('mountpoint'),
                    fstype=device.get('fstype'),
                    uuid=device.get('uuid'),
                    label=device.get('label')
                )
                disks.append(disk)
                
                for child in device.get('children', []):
                    child_disk = DiskInfo(
                        name=child.get('name', ''),
                        size=child.get('size', ''),
                        type=child.get('type', ''),
                        mountpoint=child.get('mountpoint'),
                        fstype=child.get('fstype'),
                        uuid=child.get('uuid'),
                        label=child.get('label')
                    )
                    disks.append(child_disk)
            
            self._enhance_with_df_data(disks)
            return disks
        except json.JSONDecodeError as e:
            print(f"{Color.FAIL}Error parsing disk info: {e}{Color.ENDC}")
            return []
    
    def _enhance_with_df_data(self, disks: List[DiskInfo]):
        exit_code, output, _ = self.run_command(['df', '-h'])
        if exit_code != 0:
            return
        
        lines = output.strip().split('\n')[1:]
        df_data = {}
        
        for line in lines:
            parts = line.split()
            if len(parts) >= 6:
                device = parts[0].split('/')[-1] if '/' in parts[0] else parts[0]
                df_data[device] = {
                    'used': parts[2],
                    'avail': parts[3],
                    'use_percent': parts[4]
                }
        
        for disk in disks:
            if disk.name in df_data:
                data = df_data[disk.name]
                disk.used = data['used']
                disk.avail = data['avail']
                disk.use_percent = data['use_percent']
    
    def display_disk_overview(self):
        print(f"\n{Color.BOLD}=== DISK OVERVIEW ==={Color.ENDC}\n")
        
        disks = self.get_disk_info()
        if not disks:
            print(f"{Color.WARNING}No disk information available{Color.ENDC}")
            return
        
        physical_disks = [d for d in disks if d.type == 'disk']
        partitions = [d for d in disks if d.type == 'part']
        lvm_volumes = [d for d in disks if d.type == 'lvm']
        
        if physical_disks:
            print(f"{Color.OKBLUE}Physical Disks:{Color.ENDC}")
            for disk in physical_disks:
                print(f"  {Color.BOLD}/dev/{disk.name}{Color.ENDC}")
                print(f"    Size: {disk.size}")
                print()
        
        if partitions:
            print(f"{Color.OKBLUE}Partitions:{Color.ENDC}")
            for part in partitions:
                status = f"{Color.OKGREEN}[MOUNTED]{Color.ENDC}" if part.mountpoint else f"{Color.WARNING}[UNMOUNTED]{Color.ENDC}"
                
                print(f"  {Color.BOLD}/dev/{part.name}{Color.ENDC} {status}")
                print(f"    Size: {part.size}")
                if part.fstype:
                    print(f"    Filesystem: {part.fstype}")
                if part.mountpoint:
                    print(f"    Mounted at: {part.mountpoint}")
                if part.used:
                    print(f"    Used: {part.used} / Available: {part.avail} ({part.use_percent})")
                if part.label:
                    print(f"    Label: {part.label}")
                print()
        
        if lvm_volumes:
            print(f"{Color.OKBLUE}LVM Volumes:{Color.ENDC}")
            for lvm in lvm_volumes:
                print(f"  {Color.BOLD}/dev/{lvm.name}{Color.ENDC}")
                print(f"    Size: {lvm.size}")
                if lvm.mountpoint:
                    print(f"    Mounted at: {lvm.mountpoint}")
                if lvm.used:
                    print(f"    Used: {lvm.used} / Available: {lvm.avail} ({lvm.use_percent})")
                print()
    
    def get_lvm_info(self) -> Dict:
        lvm_info = {'physical_volumes': [], 'volume_groups': [], 'logical_volumes': []}
        
        exit_code, output, _ = self.run_command(['pvs', '--reportformat', 'json'], require_root=True)
        if exit_code == 0:
            try:
                data = json.loads(output)
                lvm_info['physical_volumes'] = data.get('report', [{}])[0].get('pv', [])
            except:
                pass
        
        exit_code, output, _ = self.run_command(['vgs', '--reportformat', 'json'], require_root=True)
        if exit_code == 0:
            try:
                data = json.loads(output)
                lvm_info['volume_groups'] = data.get('report', [{}])[0].get('vg', [])
            except:
                pass
        
        exit_code, output, _ = self.run_command(['lvs', '--reportformat', 'json'], require_root=True)
        if exit_code == 0:
            try:
                data = json.loads(output)
                lvm_info['logical_volumes'] = data.get('report', [{}])[0].get('lv', [])
            except:
                pass
        
        return lvm_info
    
    def display_lvm_info(self):
        if not self.check_root_privileges():
            print(f"{Color.WARNING}Root privileges required for LVM information{Color.ENDC}")
            return
        
        print(f"\n{Color.BOLD}=== LVM INFORMATION ==={Color.ENDC}\n")
        
        lvm_info = self.get_lvm_info()
        
        pvs = lvm_info.get('physical_volumes', [])
        if pvs:
            print(f"{Color.OKBLUE}Physical Volumes:{Color.ENDC}")
            for pv in pvs:
                print(f"  {Color.BOLD}{pv.get('pv_name', 'N/A')}{Color.ENDC}")
                print(f"    VG Name: {pv.get('vg_name', 'N/A')}")
                print(f"    Size: {pv.get('pv_size', 'N/A')}")
                print(f"    Free: {pv.get('pv_free', 'N/A')}")
                print()
        
        vgs = lvm_info.get('volume_groups', [])
        if vgs:
            print(f"{Color.OKBLUE}Volume Groups:{Color.ENDC}")
            for vg in vgs:
                print(f"  {Color.BOLD}{vg.get('vg_name', 'N/A')}{Color.ENDC}")
                print(f"    Size: {vg.get('vg_size', 'N/A')}")
                print(f"    Free: {vg.get('vg_free', 'N/A')}")
                print(f"    PV Count: {vg.get('pv_count', 'N/A')}")
                print()
        
        lvs = lvm_info.get('logical_volumes', [])
        if lvs:
            print(f"{Color.OKBLUE}Logical Volumes:{Color.ENDC}")
            for lv in lvs:
                print(f"  {Color.BOLD}{lv.get('lv_name', 'N/A')}{Color.ENDC}")
                print(f"    VG Name: {lv.get('vg_name', 'N/A')}")
                print(f"    Size: {lv.get('lv_size', 'N/A')}")
                print()
        
        if not pvs and not vgs and not lvs:
            print(f"{Color.WARNING}No LVM configuration found{Color.ENDC}")
    
    def backup_partition_table(self, device: str) -> Optional[str]:
        if not self.check_root_privileges():
            print(f"{Color.FAIL}Root privileges required{Color.ENDC}")
            return None
        
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        device_name = device.split('/')[-1]
        backup_file = os.path.join(self.backup_dir, f"{device_name}_partition_table_{timestamp}.backup")
        
        exit_code, output, error = self.run_command(['sfdisk', '-d', device], require_root=True)
        
        if exit_code != 0:
            print(f"{Color.FAIL}Error backing up partition table: {error}{Color.ENDC}")
            return None
        
        try:
            with open(backup_file, 'w') as f:
                f.write(output)
            print(f"{Color.OKGREEN}Partition table backed up to: {backup_file}{Color.ENDC}")
            return backup_file
        except Exception as e:
            print(f"{Color.FAIL}Error writing backup file: {e}{Color.ENDC}")
            return None
    
    def confirm_operation(self, message: str, risk_level: OperationRisk) -> bool:
        risk_colors = {
            OperationRisk.SAFE: Color.OKGREEN,
            OperationRisk.LOW: Color.OKBLUE,
            OperationRisk.MEDIUM: Color.WARNING,
            OperationRisk.HIGH: Color.FAIL,
            OperationRisk.CRITICAL: Color.FAIL + Color.BOLD
        }
        
        color = risk_colors.get(risk_level, Color.WARNING)
        
        print(f"\n{color}{'='*80}{Color.ENDC}")
        print(f"{color}RISK LEVEL: {risk_level.value.upper()}{Color.ENDC}")
        print(f"{color}{'='*80}{Color.ENDC}")
        print(f"\n{message}\n")
        
        if risk_level in [OperationRisk.HIGH, OperationRisk.CRITICAL]:
            response = input(f"{Color.FAIL}Type 'I UNDERSTAND THE RISKS' to continue: {Color.ENDC}")
            return response == "I UNDERSTAND THE RISKS"
        else:
            response = input(f"Type 'yes' to continue: ")
            return response.lower() in ['yes', 'y']
    
    def analyze_space_usage(self, path: str = "/"):
        print(f"\n{Color.BOLD}=== SPACE USAGE ANALYSIS: {path} ==={Color.ENDC}\n")
        
        if not os.path.exists(path):
            print(f"{Color.FAIL}Path does not exist: {path}{Color.ENDC}")
            return
        
        try:
            total, used, free = shutil.disk_usage(path)
            
            print(f"Total: {self._format_bytes(total)}")
            print(f"Used:  {self._format_bytes(used)} ({used/total*100:.1f}%)")
            print(f"Free:  {self._format_bytes(free)} ({free/total*100:.1f}%)")
            print()
        except Exception as e:
            print(f"{Color.FAIL}Error getting disk usage: {e}{Color.ENDC}")
            return
        
        print(f"{Color.OKBLUE}Top 10 space consumers:{Color.ENDC}\n")
        
        exit_code, output, error = self.run_command(['du', '-h', '--max-depth=1', path])
        
        if exit_code == 0:
            lines = output.strip().split('\n')
            items = []
            for line in lines:
                parts = line.split('\t')
                if len(parts) == 2:
                    size, name = parts
                    items.append((size, name))
            
            items.sort(reverse=True)
            
            for size, name in items[:10]:
                print(f"  {size:>10s}  {name}")
        else:
            print(f"{Color.WARNING}Unable to analyze space usage{Color.ENDC}")
    
    def _format_bytes(self, bytes_val: int) -> str:
        for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
            if bytes_val < 1024.0:
                return f"{bytes_val:.2f} {unit}"
            bytes_val /= 1024.0
        return f"{bytes_val:.2f} PB"
    
    def list_backups(self):
        print(f"\n{Color.BOLD}=== PARTITION TABLE BACKUPS ==={Color.ENDC}\n")
        
        if not os.path.exists(self.backup_dir):
            print(f"{Color.WARNING}No backups found{Color.ENDC}")
            return
        
        backups = [f for f in os.listdir(self.backup_dir) if f.endswith('.backup')]
        
        if not backups:
            print(f"{Color.WARNING}No backups found{Color.ENDC}")
            return
        
        backups.sort(reverse=True)
        
        for backup in backups:
            full_path = os.path.join(self.backup_dir, backup)
            size = os.path.getsize(full_path)
            mtime = datetime.fromtimestamp(os.path.getmtime(full_path))
            
            print(f"  {Color.BOLD}{backup}{Color.ENDC}")
            print(f"    Size: {size} bytes")
            print(f"    Created: {mtime.strftime('%Y-%m-%d %H:%M:%S')}")
            print(f"    Path: {full_path}")
            print()

def main():
    parser = argparse.ArgumentParser(
        description='Obsidian Cloud Storage Manager',
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    parser.add_argument('command', choices=['overview', 'lvm', 'backup', 'analyze', 'list-backups'],
                       help='Command to execute')
    parser.add_argument('--device', help='Device path (e.g., /dev/sda)')
    parser.add_argument('--path', default='/', help='Path for analysis')
    
    args = parser.parse_args()
    
    manager = StorageManager()
    manager.print_banner()
    
    if args.command == 'overview':
        manager.display_disk_overview()
    elif args.command == 'lvm':
        manager.display_lvm_info()
    elif args.command == 'backup':
        if not args.device:
            print(f"{Color.FAIL}--device required for backup command{Color.ENDC}")
            sys.exit(1)
        manager.backup_partition_table(args.device)
    elif args.command == 'analyze':
        manager.analyze_space_usage(args.path)
    elif args.command == 'list-backups':
        manager.list_backups()

if __name__ == '__main__':
    main()
