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
    return WillPopScope(
      onWillPop: () async => false, // Desactivar el botón de volver hacia atrás
      child: Scaffold(
        appBar: AppBar(
          title: Text("Selecciona Filtros"),
          backgroundColor: Color.fromARGB(255, 63, 214, 63), // Fondo del AppBar
          automaticallyImplyLeading: false, // Ocultar el botón de volver hacia atrás en AppBar
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
        body: Container(
          color: Colors.white, // Fondo blanco para toda la página
          child: ListView(
            children: tempCategories.map((category) {
              return Container(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10), // Margen alrededor de cada categoría
                decoration: BoxDecoration(
                  color: Colors.grey, // Fondo gris para las categorías
                  border: Border.all(color: Colors.black, width: 2), // Borde negro
                  borderRadius: BorderRadius.circular(10), // Borde redondeado
                ),
                child: Theme(
                  data: ThemeData(
                    checkboxTheme: CheckboxThemeData(
                      fillColor: MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.selected)) {
                          return Color.fromARGB(255, 63, 214, 63); // Color verde para el check seleccionado
                        }
                        return Colors.white; // Color blanco para el check no seleccionado
                      }),
                      checkColor: MaterialStateProperty.all(Colors.black), // Color negro para el check en ambos estados
                    ),
                  ),
                  child: ExpansionTile(
                    backgroundColor: Colors.grey, // Fondo gris para las categorías
                    title: Text(
                      category.name,
                      style: TextStyle(color: Colors.white), // Texto en blanco para mejor contraste
                    ),
                    initiallyExpanded: true, // Empezar abiertos
                    children: category.subcategories.keys.map((subcat) {
                      return Container(
                        color: Colors.white, // Fondo blanco para las subcategorías
                        child: CheckboxListTile(
                          title: Text(subcat),
                          value: category.subcategories[subcat],
                          onChanged: (bool? value) {
                            setState(() {
                              category.subcategories[subcat] = value!;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}








