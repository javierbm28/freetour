class Category {
  String name;
  Map<String, bool> subcategories;

  Category(this.name, List<String> subcategories)
      : this.subcategories = Map.fromIterable(subcategories,
            key: (subcat) => subcat, value: (subcat) => false);

  bool isVisible() => subcategories.values.any((v) => v);
}

List<Category> categories = [
  Category("Comer y beber", ["Restaurante", "Bares", "Cafeteria", "Postres", "Tapas"]),
  Category("Qué hacer", ["Sitios de interés", "Vida nocturna", "Música en directo", "Peliculas", "Museos"]),
  Category("Compras", ["Supermercado", "Belleza", "Concesionarios", "Centro comerciales", "Electronica"]),
  Category("Servicios", ["Hoteles", "Alquiler de coche", "Gasolinerias", "Estaciones de recarga", "Aparcamientos", "Hospitales y clinicas", "Farmacias"]),
];
