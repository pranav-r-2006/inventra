import 'package:flutter/material.dart';
import 'db_helper.dart';

class AddProductPage extends StatefulWidget {
  final Map<String, dynamic>? product;

  AddProductPage({this.product});

  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final quantityController = TextEditingController();
  final priceController = TextEditingController();
  final expiryController = TextEditingController();

  final List<String> _units = ['Nos', 'Kg', 'Litre', 'Pack', 'Box'];
  String _selectedUnit = 'Nos';

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      nameController.text = widget.product!['name'];
      quantityController.text = widget.product!['quantity'].toString();
      priceController.text = widget.product!['price'].toString();
      expiryController.text = widget.product!['expiry'];
      _selectedUnit = widget.product!['unit'] ?? 'Nos';
    }
  }

  void _saveProduct() async {
    if (_formKey.currentState!.validate()) {
      final product = {
        'name': nameController.text,
        'quantity': int.parse(quantityController.text),
        'unit': _selectedUnit,
        'price': double.parse(priceController.text),
        'expiry': expiryController.text,
      };

      if (widget.product != null) {
        product['id'] = widget.product!['id'];
        await DBHelper().updateProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product updated')),
        );
      } else {
        await DBHelper().insertProduct(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Product added')),
        );
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product != null ? 'Edit Product' : 'Add Product'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Product Name'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter name' : null,
              ),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: quantityController,
                      decoration: InputDecoration(labelText: 'Quantity'),
                      keyboardType: TextInputType.number,
                      validator: (value) =>
                          value!.isEmpty ? 'Please enter quantity' : null,
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnit,
                      items: _units.map((unit) {
                        return DropdownMenuItem(
                          value: unit,
                          child: Text(unit),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedUnit = value!;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Unit'),
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: priceController,
                decoration: InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter price' : null,
              ),
              TextFormField(
                controller: expiryController,
                decoration: InputDecoration(labelText: 'Expiry Date'),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (pickedDate != null) {
                    expiryController.text =
                        pickedDate.toIso8601String().split('T')[0];
                  }
                },
                validator: (value) =>
                    value!.isEmpty ? 'Please enter expiry date' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProduct,
                child: Text(widget.product != null ? 'Update' : 'Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
