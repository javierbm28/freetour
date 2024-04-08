import 'package:flutter/material.dart';

class MapaFreeTour extends StatefulWidget {
   MapaFreeTour({super.key});

  @override
  State<MapaFreeTour> createState() => _MapaFreeTourState();
}

class _MapaFreeTourState extends State<MapaFreeTour> {
  String rutaPersonalizada = 'Ruta personalizada';

  String zonaPeligrosa = 'Zona peligrosa';

  String planNocturno = 'Plan nocturno';

  String transporteDeRuta = 'Transporte de ruta';

  List<String> opcionesRuta = ['Zona Sagrada Familia', 'Zona Glories', 'Zona Passeig de gracia', 'Zona Pedralbes', 'Ruta personalizada'];

  List<String> opcionesPeligro = ['La Mina', 'Sant Roc', 'El Raval', 'Sant Cosme', 'Zona peligrosa'];

  List<String> opcionesPlan = ['Pub', 'Discotecas', 'Casinos', 'Entretenimiento para adultos', 'Plan nocturno'];

  List<String> opcionesTransporte = ['Coche', 'Bicicleta', 'Autobus', 'Motocicleta', 'Transporte de ruta'];

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        body: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DropdownButton<String>(
                        value: rutaPersonalizada,
                        items: opcionesRuta.map((String opcion){
                          return DropdownMenuItem(
                            value: opcion,
                            child: Text(opcion),
                            );
                        }).toList(), 
                        onChanged: (String?newValue){
                          if(newValue != null){
                            setState(() {
                              rutaPersonalizada = newValue;
                            });
                          }
                        },
                        ),
            
                      DropdownButton<String>(
                        value: zonaPeligrosa,
                        items: opcionesPeligro.map((String opcion){
                          return DropdownMenuItem(
                            value: opcion,
                            child: Text(opcion),
                            );
                        }).toList(), 
                        onChanged: (String?newValue){
                          if(newValue != null){
                            setState(() {
                               zonaPeligrosa = newValue;
                            });
                          }
                        },
                        ),
            
                        DropdownButton<String>(
                        value: planNocturno,
                        items: opcionesPlan.map((String opcion){
                          return DropdownMenuItem(
                            value: opcion,
                            child: Text(opcion),
                            );
                        }).toList(), 
                        onChanged: (String?newValue){
                          if(newValue != null){
                            setState(() {
                              planNocturno = newValue;
                            });
                          }
                        },
                        ),
            
                        DropdownButton<String>(
                        value: transporteDeRuta,
                        items: opcionesTransporte.map((String opcion){
                          return DropdownMenuItem(
                            value: opcion,
                            child: Text(opcion),
                            );
                        }).toList(), 
                        onChanged: (String?newValue){
                          if(newValue != null){
                            setState(() {
                              transporteDeRuta = newValue;
                            });
                          }
                        },
                        ),
                    ],
                  ),
   
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () {}, 
                        child: const Text("Agregar punto de interes")
                      ),

                      const SizedBox(width: 20,),

                      ElevatedButton(
                        onPressed: () {}, 
                        child: const Text("Crear ruta personalizada")
                      ),
                    ],
                  )
                ],
            ),
          ),
        ),
    );
  }
}