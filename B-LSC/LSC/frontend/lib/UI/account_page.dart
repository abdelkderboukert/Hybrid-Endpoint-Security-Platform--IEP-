import 'package:fluent_ui/fluent_ui.dart';
import 'package:frontend/models/models.dart'; // Assuming your Admin and Server models are here
import 'package:frontend/services/api_service.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<AccountPage> {
  // Store the future in the state to prevent re-fetching on every build
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchData();
  }

  // A helper method to fetch both admin and server data in parallel
  Future<Map<String, dynamic>> _fetchData() async {
    // Use Future.wait for more efficient parallel fetching
    final results = await Future.wait([
      ApiService().getAdminProfile(),
      ApiService().registerServer(),
    ]);

    return {
      'admin': results[0] as Admin,
      'server':
          (results[1]
              as Map<
                String,
                dynamic
              >)['server_data'], // Extract the server data
    };
  }

  // Function to refresh the data
  void _refreshData() {
    setState(() {
      _dataFuture = _fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ScaffoldPage(
      header: PageHeader(
        title: const Text('Account & Server Profile'),
        commandBar: CommandBar(
          primaryItems: [
            CommandBarButton(
              icon: const Icon(FluentIcons.refresh),
              label: const Text('Refresh'),
              onPressed: _refreshData,
            ),
          ],
        ),
      ),
      content: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: ProgressRing());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData &&
              snapshot.data!['admin'] != null &&
              snapshot.data!['server'] != null) {
            final admin = snapshot.data!['admin'] as Admin;
            final server = Server.fromJson(snapshot.data!['server']);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAdminProfileCard(context, admin),
                  const SizedBox(height: 24),
                  _buildServerInfoCard(context, server),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data found.'));
          }
        },
      ),
    );
  }

  // --- Widget Builders for Cleaner Code ---

  /// Builds the card displaying the admin's profile information.
  Widget _buildAdminProfileCard(BuildContext context, Admin admin) {
    final typography = FluentTheme.of(context).typography;
    return Card(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Admin Profile', style: typography.subtitle),
          const SizedBox(height: 16),
          _InfoTile(
            icon: FluentIcons.contact,
            label: 'Username',
            value: admin.username,
          ),
          _InfoTile(icon: FluentIcons.mail, label: 'Email', value: admin.email),
          _InfoTile(
            icon: FluentIcons.verified_brand_solid,
            label: 'License Active',
            value: admin.license == null ? 'Yes' : 'No',
          ),
          _InfoTile(
            icon: FluentIcons.map_layers,
            label: 'Layer',
            value: admin.layer?.toString(),
          ),
          _InfoTile(
            icon: FluentIcons.calendar,
            label: 'Date Joined',
            value:
                admin.dateJoined?.toLocal().toString().split(' ')[0] ?? 'N/A',
          ),
        ],
      ),
    );
  }

  /// Builds the card displaying detailed server information using expanders.
  Widget _buildServerInfoCard(BuildContext context, Server server) {
    final typography = FluentTheme.of(context).typography;
    return Card(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Server Information', style: typography.subtitle),
          const SizedBox(height: 12),
          _InfoTile(
            icon: FluentIcons.server,
            label: 'Hostname',
            value: server.hostname,
          ),
          _InfoTile(
            icon: FluentIcons.network_device_scanning,
            label: 'IP Address',
            value: server.ipAddress,
          ),
          const SizedBox(height: 12),
          Expander(
            header: const Text('Operating System'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoTile(label: 'OS Name', value: server.osName),
                _InfoTile(label: 'Version', value: server.osVersion),
                _InfoTile(label: 'Architecture', value: server.osArchitecture),
                _InfoTile(label: 'Build', value: server.osBuild),
              ],
            ),
          ),
          Expander(
            header: const Text('Hardware'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoTile(label: 'CPU', value: server.cpuInfo),
                _InfoTile(
                  label: 'Total RAM',
                  value: '${server.totalRamGb?.toStringAsFixed(2) ?? 'N/A'} GB',
                ),
                _InfoTile(
                  label: 'Available Storage',
                  value:
                      '${server.availableStorageGb?.toStringAsFixed(2) ?? 'N/A'} GB',
                ),
              ],
            ),
          ),
          Expander(
            header: const Text('Network Details'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoTile(label: 'MAC Address', value: server.macAddress),
                _InfoTile(
                  label: 'Default Gateway',
                  value: server.defaultGateway,
                ),
                _InfoTile(
                  label: 'DNS Servers',
                  value: server.dnsServers?.join(', '),
                ),
              ],
            ),
          ),
          Expander(
            header: const Text('Security & Status'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoTile(label: 'Firewall', value: server.firewallStatus),
                _InfoTile(label: 'Antivirus', value: server.antivirusStatus),
                _InfoTile(
                  label: 'Last Boot Time',
                  value: server.lastBootTime?.toLocal().toString().split(
                    '.',
                  )[0],
                ),
                _InfoTile(
                  label: 'Uptime',
                  value:
                      '${server.uptimeHours?.toStringAsFixed(2) ?? 'N/A'} hours',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A reusable helper widget for displaying a labeled piece of information.
class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.label, this.value, this.icon});

  final String label;
  final String? value;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: FluentTheme.of(context).inactiveColor),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 120, // Consistent label width
            child: Text(
              '$label:',
              style: FluentTheme.of(context).typography.bodyStrong,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: FluentTheme.of(context).typography.body,
            ),
          ),
        ],
      ),
    );
  }
}
