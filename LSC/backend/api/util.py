# import platform
# import socket
# import psutil
# import getpass
# import os
# import subprocess
# import json
# from datetime import datetime
# from typing import Dict, List, Optional
# import uuid

# class SystemDetector:
#     """Utility class to detect system information for server auto-registration."""
    
#     def __init__(self):
#         self.system_info = {}
        
#     def get_basic_system_info(self) -> Dict:
#         """Get basic system information."""
#         try:
#             return {
#                 'server_name': platform.node(),
#                 'hostname': socket.gethostname(),
#                 'os_name': f"{platform.system()} {platform.release()}",
#                 'os_version': platform.version(),
#                 'os_architecture': platform.architecture()[0],
#                 'os_build': platform.platform(),
#             }
#         except Exception as e:
#             print(f"Error getting basic system info: {e}")
#             return {}
    
#     def get_windows_domain_info(self) -> Dict:
#         """Get Windows domain/workgroup information."""
#         domain_info = {'domain': '', 'workgroup': ''}
        
#         if platform.system() == 'Windows':
#             try:
#                 # Try to get domain information
#                 import win32api
#                 import win32security
                
#                 try:
#                     domain = win32api.GetComputerNameEx(win32api.ComputerNameDnsDomain)
#                     if domain:
#                         domain_info['domain'] = domain
#                 except:
#                     pass
                
#                 # Get workgroup information
#                 try:
#                     result = subprocess.run(['wmic', 'computersystem', 'get', 'domain', '/value'], 
#                                           capture_output=True, text=True, timeout=10)
#                     for line in result.stdout.split('\n'):
#                         if line.startswith('Domain='):
#                             workgroup = line.split('=', 1)[1].strip()
#                             if not domain_info['domain']:
#                                 domain_info['workgroup'] = workgroup
#                             break
#                 except Exception as e:
#                     print(f"Error getting workgroup info: {e}")
                    
#             except ImportError:
#                 # Fallback method without win32 modules
#                 try:
#                     result = subprocess.run(['systeminfo'], capture_output=True, text=True, timeout=15)
#                     for line in result.stdout.split('\n'):
#                         if 'Domain:' in line:
#                             domain = line.split(':', 1)[1].strip()
#                             if domain.lower() not in ['workgroup', '(none)']:
#                                 domain_info['domain'] = domain
#                             else:
#                                 domain_info['workgroup'] = domain
#                             break
#                 except Exception as e:
#                     print(f"Error getting domain info via systeminfo: {e}")
        
#         return domain_info
    
#     def get_hardware_info(self) -> Dict:
#         """Get hardware information."""
#         try:
#             # Get CPU info
#             cpu_info = f"{platform.processor()}"
#             if not cpu_info.strip():
#                 cpu_info = f"{psutil.cpu_count(logical=False)} cores, {psutil.cpu_count(logical=True)} threads"
            
#             # Get memory info
#             memory = psutil.virtual_memory()
#             total_ram_gb = round(memory.total / (1024**3), 2)
            
#             # Get disk info (primary drive)
#             disk = psutil.disk_usage('/')
#             available_storage_gb = round(disk.free / (1024**3), 2)
            
#             return {
#                 'cpu_info': cpu_info,
#                 'total_ram_gb': total_ram_gb,
#                 'available_storage_gb': available_storage_gb,
#             }
#         except Exception as e:
#             print(f"Error getting hardware info: {e}")
#             return {}
    
#     def get_network_info(self) -> Dict:
#         """Get network interface information."""
#         network_info = {
#             'ip_address': None,
#             'mac_address': None,
#             'network_interfaces': [],
#             'dns_servers': [],
#             'default_gateway': None,
#         }
        
#         try:
#             # Get primary IP
#             s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
#             s.connect(("8.8.8.8", 80))
#             primary_ip = s.getsockname()[0]
#             s.close()
#             network_info['ip_address'] = primary_ip
            
#             # Get all network interfaces
#             interfaces = psutil.net_if_addrs()
#             stats = psutil.net_if_stats()
            
#             for interface_name, addresses in interfaces.items():
#                 if interface_name in stats and stats[interface_name].isup:
#                     interface_info = {
#                         'name': interface_name,
#                         'addresses': [],
#                         'is_up': True,
#                     }
                    
#                     for addr in addresses:
#                         if addr.family == socket.AF_INET:  # IPv4
#                             interface_info['addresses'].append({
#                                 'type': 'IPv4',
#                                 'address': addr.address,
#                                 'netmask': addr.netmask,
#                             })
#                             # Set primary MAC address
#                             if addr.address == primary_ip and not network_info['mac_address']:
#                                 for mac_addr in addresses:
#                                     if mac_addr.family == psutil.AF_LINK:
#                                         network_info['mac_address'] = mac_addr.address
#                                         break
#                         elif addr.family == psutil.AF_LINK:  # MAC address
#                             interface_info['mac_address'] = addr.address
                    
#                     if interface_info['addresses']:
#                         network_info['network_interfaces'].append(interface_info)
            
#             # Try to get DNS servers and gateway (Windows specific)
#             if platform.system() == 'Windows':
#                 try:
#                     result = subprocess.run(['ipconfig', '/all'], capture_output=True, text=True, timeout=10)
#                     lines = result.stdout.split('\n')
                    
#                     for i, line in enumerate(lines):
#                         if 'DNS Servers' in line:
#                             dns_line = line.split(':', 1)[1].strip()
#                             if dns_line:
#                                 network_info['dns_servers'].append(dns_line)
#                             # Check next lines for additional DNS servers
#                             j = i + 1
#                             while j < len(lines) and lines[j].strip().startswith((' ', '\t')):
#                                 dns_server = lines[j].strip()
#                                 if dns_server:
#                                     network_info['dns_servers'].append(dns_server)
#                                 j += 1
#                         elif 'Default Gateway' in line:
#                             gateway = line.split(':', 1)[1].strip()
#                             if gateway:
#                                 network_info['default_gateway'] = gateway
#                 except Exception as e:
#                     print(f"Error getting Windows network details: {e}")
            
#         except Exception as e:
#             print(f"Error getting network info: {e}")
        
#         return network_info
    
#     def get_current_user_info(self) -> Dict:
#         """Get current logged-in user information."""
#         try:
#             current_user = getpass.getuser()
#             user_profile_path = os.path.expanduser('~')
            
#             # Check if user has admin privileges
#             is_admin_user = False
#             if platform.system() == 'Windows':
#                 try:
#                     import ctypes
#                     is_admin_user = ctypes.windll.shell32.IsUserAnAdmin() != 0
#                 except Exception:
#                     pass
#             else:
#                 is_admin_user = os.getuid() == 0
            
#             return {
#                 'current_user': current_user,
#                 'user_profile_path': user_profile_path,
#                 'is_admin_user': is_admin_user,
#             }
#         except Exception as e:
#             print(f"Error getting user info: {e}")
#             return {}
    
#     def get_security_status(self) -> Dict:
#         """Get security status information."""
#         security_info = {
#             'antivirus_status': 'Unknown',
#             'firewall_status': 'Unknown',
#         }
        
#         if platform.system() == 'Windows':
#             try:
#                 # Check Windows Defender status
#                 result = subprocess.run(['powershell', 'Get-MpComputerStatus'], 
#                                       capture_output=True, text=True, timeout=15)
#                 if 'AntivirusEnabled' in result.stdout:
#                     if 'True' in result.stdout:
#                         security_info['antivirus_status'] = 'Windows Defender Active'
#                     else:
#                         security_info['antivirus_status'] = 'Windows Defender Inactive'
                
#                 # Check firewall status
#                 result = subprocess.run(['netsh', 'advfirewall', 'show', 'allprofiles', 'state'], 
#                                       capture_output=True, text=True, timeout=10)
#                 if 'State                                 ON' in result.stdout:
#                     security_info['firewall_status'] = 'Windows Firewall Active'
#                 else:
#                     security_info['firewall_status'] = 'Windows Firewall Inactive'
                    
#             except Exception as e:
#                 print(f"Error getting security status: {e}")
        
#         return security_info
    
#     def get_system_uptime(self) -> Dict:
#         """Get system boot time and uptime."""
#         try:
#             boot_time = datetime.fromtimestamp(psutil.boot_time())
#             uptime_seconds = (datetime.now() - boot_time).total_seconds()
#             uptime_hours = round(uptime_seconds / 3600, 2)
            
#             return {
#                 'last_boot_time': boot_time,
#                 'uptime_hours': uptime_hours,
#             }
#         except Exception as e:
#             print(f"Error getting uptime info: {e}")
#             return {}
    
#     def get_complete_system_info(self) -> Dict:
#         """Get all system information combined."""
#         system_info = {}
        
#         # Gather all information
#         system_info.update(self.get_basic_system_info())
#         system_info.update(self.get_windows_domain_info())
#         system_info.update(self.get_hardware_info())
#         system_info.update(self.get_network_info())
#         system_info.update(self.get_current_user_info())
#         system_info.update(self.get_security_status())
#         system_info.update(self.get_system_uptime())
        
#         # Add metadata
#         system_info.update({
#             'auto_detected': True,
#             'detection_timestamp': datetime.now(),
#             'server_type': 'Local',  # Default, can be overridden
#         })
        
#         return system_info

# def detect_or_create_server_info() -> Dict:
#     """
#     Main function to detect system information.
#     Returns a dictionary suitable for Server model creation/update.
#     """
#     detector = SystemDetector()
#     return detector.get_complete_system_info()

# # Example usage
# if __name__ == "__main__":
#     info = detect_or_create_server_info()
#     print(json.dumps(info, indent=2, default=str))


import platform
import socket
import psutil
import getpass
import os
import subprocess
import json
from datetime import datetime
from typing import Dict, List, Optional
import uuid

class SystemDetector:
    """Utility class to detect system information for server auto-registration."""
    
    def __init__(self):
        self.system_info = {}
        
    def get_basic_system_info(self) -> Dict:
        """Get basic system information."""
        try:
            return {
                'server_name': platform.node(),
                'hostname': socket.gethostname(),
                'os_name': f"{platform.system()} {platform.release()}",
                'os_version': platform.version(),
                'os_architecture': platform.architecture()[0],
                'os_build': platform.platform(),
            }
        except Exception as e:
            print(f"Error getting basic system info: {e}")
            return {}
    
    def get_windows_domain_info(self) -> Dict:
        """Get Windows domain/workgroup information."""
        domain_info = {'domain': '', 'workgroup': ''}
        
        if platform.system() == 'Windows':
            try:
                # Try to get domain information
                import win32api
                import win32security
                
                try:
                    domain = win32api.GetComputerNameEx(win32api.ComputerNameDnsDomain)
                    if domain:
                        domain_info['domain'] = domain
                except:
                    pass
                
                # Get workgroup information
                try:
                    # CHANGED: Added creationflags to hide the window
                    result = subprocess.run(['wmic', 'computersystem', 'get', 'domain', '/value'], 
                                            capture_output=True, text=True, timeout=10, 
                                            creationflags=subprocess.CREATE_NO_WINDOW)
                    for line in result.stdout.split('\n'):
                        if line.startswith('Domain='):
                            workgroup = line.split('=', 1)[1].strip()
                            if not domain_info['domain']:
                                domain_info['workgroup'] = workgroup
                            break
                except Exception as e:
                    print(f"Error getting workgroup info: {e}")
                    
            except ImportError:
                # Fallback method without win32 modules
                try:
                    # CHANGED: Added creationflags to hide the window
                    result = subprocess.run(['systeminfo'], capture_output=True, text=True, timeout=15, 
                                            creationflags=subprocess.CREATE_NO_WINDOW)
                    for line in result.stdout.split('\n'):
                        if 'Domain:' in line:
                            domain = line.split(':', 1)[1].strip()
                            if domain.lower() not in ['workgroup', '(none)']:
                                domain_info['domain'] = domain
                            else:
                                domain_info['workgroup'] = domain
                            break
                except Exception as e:
                    print(f"Error getting domain info via systeminfo: {e}")
        
        return domain_info
    
    def get_hardware_info(self) -> Dict:
        """Get hardware information."""
        try:
            # Get CPU info
            cpu_info = f"{platform.processor()}"
            if not cpu_info.strip():
                cpu_info = f"{psutil.cpu_count(logical=False)} cores, {psutil.cpu_count(logical=True)} threads"
            
            # Get memory info
            memory = psutil.virtual_memory()
            total_ram_gb = round(memory.total / (1024**3), 2)
            
            # Get disk info (primary drive)
            # On Windows, os.getenv('SystemDrive', 'C:') ensures we get the main drive (e.g., C:\)
            drive = os.getenv('SystemDrive', '') + os.path.sep
            disk = psutil.disk_usage(drive)
            available_storage_gb = round(disk.free / (1024**3), 2)
            
            return {
                'cpu_info': cpu_info,
                'total_ram_gb': total_ram_gb,
                'available_storage_gb': available_storage_gb,
            }
        except Exception as e:
            print(f"Error getting hardware info: {e}")
            return {}
    
    def get_network_info(self) -> Dict:
        """Get network interface information."""
        network_info = {
            'ip_address': None,
            'mac_address': None,
            'network_interfaces': [],
            'dns_servers': [],
            'default_gateway': None,
        }
        
        try:
            # Get primary IP
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(("8.8.8.8", 80))
            primary_ip = s.getsockname()[0]
            s.close()
            network_info['ip_address'] = primary_ip
            
            # Get all network interfaces
            interfaces = psutil.net_if_addrs()
            stats = psutil.net_if_stats()
            
            for interface_name, addresses in interfaces.items():
                if interface_name in stats and stats[interface_name].isup:
                    interface_info = {
                        'name': interface_name,
                        'addresses': [],
                        'is_up': True,
                    }
                    
                    for addr in addresses:
                        if addr.family == socket.AF_INET:  # IPv4
                            interface_info['addresses'].append({
                                'type': 'IPv4',
                                'address': addr.address,
                                'netmask': addr.netmask,
                            })
                            # Set primary MAC address
                            if addr.address == primary_ip and not network_info['mac_address']:
                                for mac_addr in addresses:
                                    if mac_addr.family == psutil.AF_LINK:
                                        network_info['mac_address'] = mac_addr.address
                                        break
                        elif addr.family == psutil.AF_LINK:  # MAC address
                            interface_info['mac_address'] = addr.address
                    
                    if interface_info['addresses']:
                        network_info['network_interfaces'].append(interface_info)
            
            # Try to get DNS servers and gateway (Windows specific)
            if platform.system() == 'Windows':
                try:
                    # CHANGED: Added creationflags to hide the window
                    result = subprocess.run(['ipconfig', '/all'], capture_output=True, text=True, timeout=10, 
                                            creationflags=subprocess.CREATE_NO_WINDOW)
                    lines = result.stdout.split('\n')
                    
                    for i, line in enumerate(lines):
                        if 'DNS Servers' in line:
                            dns_line = line.split(':', 1)[1].strip()
                            if dns_line:
                                network_info['dns_servers'].append(dns_line)
                            # Check next lines for additional DNS servers
                            j = i + 1
                            while j < len(lines) and lines[j].strip() and not lines[j].strip().endswith(':'):
                                dns_server = lines[j].strip()
                                if dns_server:
                                    network_info['dns_servers'].append(dns_server)
                                j += 1
                        elif 'Default Gateway' in line:
                            gateway = line.split(':', 1)[1].strip()
                            if gateway and not network_info['default_gateway']:
                                network_info['default_gateway'] = gateway
                except Exception as e:
                    print(f"Error getting Windows network details: {e}")
            
        except Exception as e:
            print(f"Error getting network info: {e}")
        
        return network_info
    
    def get_current_user_info(self) -> Dict:
        """Get current logged-in user information."""
        try:
            current_user = getpass.getuser()
            user_profile_path = os.path.expanduser('~')
            
            # Check if user has admin privileges
            is_admin_user = False
            if platform.system() == 'Windows':
                try:
                    import ctypes
                    is_admin_user = ctypes.windll.shell32.IsUserAnAdmin() != 0
                except Exception:
                    pass
            else:
                is_admin_user = os.getuid() == 0
            
            return {
                'current_user': current_user,
                'user_profile_path': user_profile_path,
                'is_admin_user': is_admin_user,
            }
        except Exception as e:
            print(f"Error getting user info: {e}")
            return {}
    
    def get_security_status(self) -> Dict:
        """Get security status information."""
        security_info = {
            'antivirus_status': 'Unknown',
            'firewall_status': 'Unknown',
        }
        
        if platform.system() == 'Windows':
            try:
                # Check Windows Defender status
                # CHANGED: Added creationflags to hide the window
                result = subprocess.run(['powershell', '-Command', 'Get-MpComputerStatus'], 
                                        capture_output=True, text=True, timeout=15, 
                                        creationflags=subprocess.CREATE_NO_WINDOW)
                if result.returncode == 0 and 'AntivirusEnabled' in result.stdout:
                    if 'True' in [line for line in result.stdout.split('\n') if 'AntivirusEnabled' in line][0]:
                        security_info['antivirus_status'] = 'Windows Defender Active'
                    else:
                        security_info['antivirus_status'] = 'Windows Defender Inactive'
                
                # Check firewall status
                # CHANGED: Added creationflags to hide the window
                result = subprocess.run(['netsh', 'advfirewall', 'show', 'allprofiles', 'state'], 
                                        capture_output=True, text=True, timeout=10, 
                                        creationflags=subprocess.CREATE_NO_WINDOW)
                if 'State' in result.stdout and 'ON' in result.stdout:
                    security_info['firewall_status'] = 'Windows Firewall Active'
                else:
                    security_info['firewall_status'] = 'Windows Firewall Inactive'
                    
            except Exception as e:
                print(f"Error getting security status: {e}")
        
        return security_info
    
    def get_system_uptime(self) -> Dict:
        """Get system boot time and uptime."""
        try:
            boot_time = datetime.fromtimestamp(psutil.boot_time())
            uptime_seconds = (datetime.now() - boot_time).total_seconds()
            uptime_hours = round(uptime_seconds / 3600, 2)
            
            return {
                'last_boot_time': boot_time,
                'uptime_hours': uptime_hours,
            }
        except Exception as e:
            print(f"Error getting uptime info: {e}")
            return {}
    
    def get_complete_system_info(self) -> Dict:
        """Get all system information combined."""
        system_info = {}
        
        # Gather all information
        system_info.update(self.get_basic_system_info())
        system_info.update(self.get_windows_domain_info())
        system_info.update(self.get_hardware_info())
        system_info.update(self.get_network_info())
        system_info.update(self.get_current_user_info())
        system_info.update(self.get_security_status())
        system_info.update(self.get_system_uptime())
        
        # Add metadata
        system_info.update({
            'auto_detected': True,
            'detection_timestamp': datetime.now(),
            'server_type': 'Local',  # Default, can be overridden
        })
        
        return system_info

def detect_or_create_server_info() -> Dict:
    """
    Main function to detect system information.
    Returns a dictionary suitable for Server model creation/update.
    """
    detector = SystemDetector()
    return detector.get_complete_system_info()

# Example usage
if __name__ == "__main__":
    info = detect_or_create_server_info()
    print(json.dumps(info, indent=2, default=str))