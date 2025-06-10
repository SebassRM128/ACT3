import 'package:flutter/material.dart';
import 'edit_inventory_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Simple Inventory App",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue, // Puedes mantener este o cambiarlo si quieres
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<Map<String, dynamic>> _inventoryItems = [];
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();

  // Updated controllers for the new fields
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _problemDescriptionController = TextEditingController();
  final TextEditingController _repairCostController = TextEditingController();
  final TextEditingController _repairTimeController = TextEditingController();
  final TextEditingController _repairStatusController = TextEditingController();


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

  void _addInventoryItem() {
    _idController.clear();
    _dateController.clear();
    _problemDescriptionController.clear();
    _repairCostController.clear();
    _repairTimeController.clear();
    _repairStatusController.clear();

    final DateTime initialDate = DateTime.now();
    _dateController.text = "${initialDate.day}/${initialDate.month}/${initialDate.year}";

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Artículo'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _idController, decoration: const InputDecoration(labelText: 'ID')),
              GestureDetector(
                onTap: () async {
                  final DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
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
              TextField(controller: _problemDescriptionController, decoration: const InputDecoration(labelText: 'Descripción del Problema')),
              TextField(controller: _repairCostController, keyboardType: TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Costo de Reparación')),
              TextField(controller: _repairTimeController, decoration: const InputDecoration(labelText: 'Tiempo de Reparación')),
              TextField(controller: _repairStatusController, decoration: const InputDecoration(labelText: 'Estado de Reparación')),
            ].map((widget) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: widget,
            )).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
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
              }

              if (id.isNotEmpty && selectedDate != null && problemDescription.isNotEmpty && repairCost != null && repairTime.isNotEmpty && repairStatus.isNotEmpty) {
                setState(() {
                  _inventoryItems.insert(0, {
                    'id': DateTime.now().millisecondsSinceEpoch.toString(),
                    'idKey': id,
                    'fecha': selectedDate,
                    'descripcionProblema': problemDescription,
                    'costoReparacion': repairCost,
                    'tiempoReparacion': repairTime,
                    'estadoReparacion': repairStatus,
                  });
                  _listKey.currentState?.insertItem(0, duration: const Duration(milliseconds: 500));
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Por favor, llena todos los campos.')),
                );
              }
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }

  void _removeInventoryItem(int index) {
    final Map<String, dynamic> removedItem = _inventoryItems.removeAt(index);
    _listKey.currentState?.removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation,
        axisAlignment: -1.0,
        child: _buildInventoryCard(removedItem),
      ),
      duration: const Duration(milliseconds: 400),
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Artículo "${removedItem["idKey"] ?? "N/A"}" eliminado')),
    );
  }

  void _editInventoryItem(int index) async {
    final Map<String, dynamic> itemToEdit = Map<String, dynamic>.from(_inventoryItems[index]);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditInventoryScreen(item: itemToEdit),
      ),
    );

    if (result != null && result is Map<String, dynamic>) {
      setState(() {
        _inventoryItems[index] = result;
      });
    }
  }

  Widget _buildInventoryCard(Map<String, dynamic> item) {
    final String id = item['idKey'] as String? ?? 'N/A';
    final String problemDescription = item['descripcionProblema'] as String? ?? 'N/A';
    final String repairCost = item['costoReparacion']?.toString() ?? 'N/A';
    final String repairTime = item['tiempoReparacion'] as String? ?? 'N/A';
    final String repairStatus = item['estadoReparacion'] as String? ?? 'N/A';

    final DateTime? date = item['fecha'] as DateTime?;
    final String formattedDate = date != null
        ? "${date.day}/${date.month}/${date.year}"
        : 'N/A';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Dismissible(
        key: Key(item['id']),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Confirmar Eliminación'),
              content: Text('¿Estás seguro de eliminar el artículo "${item["idKey"] ?? "N/A"}"?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Eliminar'),
                ),
              ],
            ),
          ) ?? false;
        },
        onDismissed: (direction) {
          final int index = _inventoryItems.indexWhere((element) => element['id'] == item['id']);
          if (index != -1) {
            _removeInventoryItem(index);
          }
        },
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: const Icon(Icons.delete, color: Colors.white),
        ),
        child: ListTile(
          title: Text('ID: $id'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Fecha: $formattedDate'),
              Text('Descripción del Problema: $problemDescription'),
              Text('Costo de Reparación: \$$repairCost'),
              Text('Tiempo de Reparación: $repairTime'),
              Text('Estado de Reparación: $repairStatus'),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              final int index = _inventoryItems.indexWhere((element) => element['id'] == item['id']);
              if (index != -1) {
                _editInventoryItem(index);
              }
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF191970), // Midnight blue color
        title: const Text(
          "Sebastian Rojas ",
          style: TextStyle(color: Colors.white), // Color del texto del título
        ),
      ),
      body: _inventoryItems.isEmpty
          ? const Center(
        // ELIMINAMOS EL TEXTO DEL CENTRO SI NO HAY ITEMS
        // child: Text('No hay artículos en el inventario. Agrega uno!'),
      )
          : AnimatedList(
        key: _listKey,
        padding: const EdgeInsets.all(8.0),
        initialItemCount: _inventoryItems.length,
        itemBuilder: (context, index, animation) {
          final item = _inventoryItems[index];
          return SizeTransition(
            sizeFactor: animation,
            child: _buildInventoryCard(item),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addInventoryItem,
        child: const Icon(Icons.add),
      ),
    );
  }
}