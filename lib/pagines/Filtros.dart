import 'package:flutter/material.dart';
import 'package:freetour/pagines/CategoriasFiltros.dart';

class Filtros extends StatefulWidget {
  final Function(List<Category>) onApplyFilters;

  Filtros({required this.onApplyFilters});

  @override
  _FiltrosState createState() => _FiltrosState();
}

class _FiltrosState extends State<Filtros> {
  List<Category> tempCategories = List.from(categories);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selecciona Filtros"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              widget.onApplyFilters(tempCategories);
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: ListView(
        children: tempCategories.map((category) {
          return ExpansionTile(
            title: Text(category.name),
            initiallyExpanded: category.isVisible(),
            children: category.subcategories.keys.map((subcat) {
              return CheckboxListTile(
                title: Text(subcat),
                value: category.subcategories[subcat],
                onChanged: (bool? value) {
                  setState(() {
                    category.subcategories[subcat] = value!;
                  });
                },
              );
            }).toList(),
          );
        }).toList(),
      ),
    );
  }
}

