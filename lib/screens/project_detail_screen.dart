import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';

class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({required this.project, super.key});

  final Project project;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(project.name),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (project.kicker.isNotEmpty)
            Text(
              project.kicker,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          Text(
            project.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(project.description),
          // The API has no image field, so only the project link is shown.
          if (project.url.isNotEmpty) ...[
            const SizedBox(height: 12),
            SelectableText('Tautan: ${project.url}'),
          ],
        ],
      ),
    );
  }
}
