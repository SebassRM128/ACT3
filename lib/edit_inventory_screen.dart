import 'package:flutter/material.dart';

class EditInventoryScreen extends StatefulWidget {
  final Map<String, dynamic> item; // Recibe el item a editar

  const EditInventoryScreen({Key? key, required this.item}) : super(key: key);

  @override
  State<EditInventoryScreen> createState() => _EditInventoryScreenState();
}

class _EditInventoryScreenState extends State<EditInventoryScreen> {
  // Updated controllers for the new fields
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _problemDescriptionController = TextEditingController();
  final TextEditingController _repairCostController = TextEditingController();
  final TextEditingController _repairTimeController = TextEditingController();
  final TextEditingController _repairStatusController = TextEditingController();


  @override
  void initState() {
    super.initState();
    // Cargar los datos del item en los controladores al inicializar
    _idController.text = widget.item['idKey'] as String? ?? '';
    _problemDescriptionController.text = widget.item['descripcionProblema'] as String? ?? '';
    _repairCostController.text = widget.item['costoReparacion']?.toString() ?? '';
    _repairTimeController.text = widget.item['tiempoReparacion'] as String? ?? '';
    _repairStatusController.text = widget.item['estadoReparacion'] as String? ?? '';

    final DateTime? date = widget.item['fecha'] as DateTime?;
    if (date != null) {
      _dateController.text = "${date.day}/${date.month}/${date.year}";
    } else {
      _dateController.text = '';
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    _dateController.dispose();
    _problemDescriptionController.dispose();
    _repairCostController.dispose();
    _repairTimeController.dispose();
    _repairStatusController.dispose();
    super.dispose();
  }

  void _updateInventoryItem() {
    final String id = _idController.text.trim();
    final String problemDescription = _problemDescriptionController.text.trim();
    final double? repairCost = double.tryParse(_repairCostController.text.trim());
    final String repairTime = _repairTimeController.text.trim();
    final String repairStatus = _repairStatusController.text.trim();

    DateTime? selectedDate;
    try {
      final parts = _dateController.text.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        selectedDate = DateTime(year, month, day);
      }
    } catch (e) {
      selectedDate = null;
      print('Error al parsear la fecha en edición: $e');
    }

    if (id.isNotEmpty && selectedDate != null && problemDescription.isNotEmpty && repairCost != null && repairTime.isNotEmpty && repairStatus.isNotEmpty) {
      // Devolver los datos actualizados a la pantalla anterior
      Navigator.pop(context, {
        'id': widget.item['id'], // Mantener el mismo ID para el Dismissible
        'idKey': id,
        'fecha': selectedDate,
        'descripcionProblema': problemDescription,
        'costoReparacion': repairCost,
        'tiempoReparacion': repairTime,
        'estadoReparacion': repairStatus,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, llena todos los campos obligatorios para actualizar, asegúrate que costo sea un número y la fecha sea válida.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Artículo de Inventario'),
        backgroundColor: const Color(0xFF191970), // Midnight blue color
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20), // Style for the title text
        iconTheme: const IconThemeData(color: Colors.white), // Color for the back button
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: const InputDecoration(labelText: 'ID'),
            ),
            const SizedBox(height: 15),
            GestureDetector(
              onTap: () async {
                DateTime initialDateForPicker;
                try {
                  // Intenta parsear la fecha actual del controlador para usarla como initialDate
                  final parts = _dateController.text.split('/');
                  initialDateForPicker = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
                } catch (e) {
                  initialDateForPicker = DateTime.now(); // Si hay error, usa la fecha actual
                }

                final DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: initialDateForPicker,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(
                          primary: const Color(0xFF191970), // Color del selector de fecha (Midnight Blue)
                          onPrimary: Colors.white, // Color del texto en el selector de fecha
                          onSurface: Colors.black87, // Color de los números y texto de la fecha
                        ),
                        dialogBackgroundColor: Theme.of(context).dialogTheme.backgroundColor, // Fondo del picker
                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            foregroundColor: const Color(0xFF191970), // Color de texto de los botones del picker (Cancelar, OK)
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) {
                  setState(() {
                    _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
                  });
                }
              },
              child: AbsorbPointer(
                child: TextField(
                  controller: _dateController,
                  decoration: const InputDecoration(
                    labelText: 'Fecha (DD/MM/AAAA)',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _problemDescriptionController,
              decoration: const InputDecoration(labelText: 'Descripción del Problema'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _repairCostController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Costo de Reparación'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _repairTimeController,
              decoration: const InputDecoration(labelText: 'Tiempo de Reparación'),
            ),
            const SizedBox(height: 15),
            TextField(
              controller: _repairStatusController,
              decoration: const InputDecoration(labelText: 'Estado de Reparación'),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateInventoryItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF191970), // Midnight blue color for the button
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Actualizar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}