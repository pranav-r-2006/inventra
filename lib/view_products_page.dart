import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'add_product_page.dart';

class ViewProductsPage extends StatefulWidget {
  @override
  _ViewProductsPageState createState() => _ViewProductsPageState();
}

class _ViewProductsPageState extends State<ViewProductsPage> {
  bool isExpiringSoon(String expiryDate) {
    try {
      final expiry = DateTime.parse(expiryDate);
      final today = DateTime.now();
      final difference = expiry.difference(today).inDays;
      return difference < 7 && difference >= 0;
    } catch (e) {
      return false;
    }
  }

  bool isExpired(String expiryDate) {
    try {
      final expiry = DateTime.parse(expiryDate);
      return DateTime.now().isAfter(expiry);
    } catch (e) {
      return false;
    }
  }

  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_filterProducts);
  }

  void _loadProducts() async {
    final products = await DBHelper().getProducts();
    setState(() {
      _products = products;
      _filteredProducts = products;
    });
  }

  void _filterProducts() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredProducts = _products.where((product) {
        return product['name'].toLowerCase().contains(query);
      }).toList();
    });
  }

  void _deleteProduct(int id, String name) async {
    await DBHelper().deleteProduct(id);
    _loadProducts();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$name deleted')),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('All Products'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by product name...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return Card(
                  child: ListTile(
                    title: Text(product['name']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Qty: ${product['quantity']} ${product['unit']} | ₹${product['price']}'),
                        Text('Expiry: ${product['expiry']}'),
                        if (isExpired(product['expiry'])) ...[
                          Text(
                            'Expired!',
                            style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ] else if (isExpiringSoon(product['expiry'])) ...[
                          Text(
                            'Expiring Soon!',
                            style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteProduct(product['id'], product['name']),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddProductPage(product: product),
                        ),
                      ).then((_) => _loadProducts());
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
