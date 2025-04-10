import 'package:flutter/material.dart';

class CreateCategoryDialog extends StatefulWidget {
  final Function onCategoryCreated;

  const CreateCategoryDialog({
    Key? key,
    required this.onCategoryCreated,
  }) : super(key: key);

  @override
  State<CreateCategoryDialog> createState() => _CreateCategoryDialogState();
}

class _CreateCategoryDialogState extends State<CreateCategoryDialog> {
  final TextEditingController _nameController = TextEditingController();
  String selectedEmoji = '🛒'; // Default emoji
  bool isCreating = false;

  final List<String> emojis = [
    '🛒',
    '⚡',
    '💧',
    '⛽',
    '🏪',
    '📱',
    '💻',
    '🚗',
    '🏠',
    '📄',
    '💼',
    '🔋'
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _createCategory() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor ingresa un nombre para la categoría')),
      );
      return;
    }

    setState(() {
      isCreating = true;
    });

    try {
      // Crear un objeto simple con los datos de la categoría
      final newCategory = {
        'name': _nameController.text.trim(),
        'emoji': selectedEmoji,
      };

      // Llamar al callback para que el HomeScreen se encargue de guardar en Firebase
      widget.onCategoryCreated(newCategory);

      // Cerrar el diálogo
      Navigator.of(context).pop();
    } catch (e) {
      print('Error creando categoría: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al crear la categoría')),
      );
      setState(() {
        isCreating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Título del diálogo
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Crear Nueva Carpeta',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Selección de emoji
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: emojis.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedEmoji = emojis[index];
                      });
                    },
                    child: Container(
                      width: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: selectedEmoji == emojis[index]
                            ? Colors.blue.withOpacity(0.3)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          emojis[index],
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Campo de nombre
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  child: Text(
                    selectedEmoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'Nombre de la carpeta',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Botón de crear
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isCreating ? null : _createCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                child: isCreating
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Crear carpeta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
