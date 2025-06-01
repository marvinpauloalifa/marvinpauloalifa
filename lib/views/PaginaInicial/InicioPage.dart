import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class InicioPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          const SizedBox(height: 40),
          const Text(
            "MediFinder 🏥",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          // Image
          const CircleAvatar(
            radius: 60,
            backgroundImage: AssetImage('assets/logo.png'),
          ),

          // Description text
          const SizedBox(height: 20),
          const Text(
            "Encontre a farmácia e seus medicamentos",
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 40),

          // Buttons
          Column(
            children: [
               ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login');
                 },
                 child: const Text("Entrar"),
                 style: ElevatedButton.styleFrom(
                   backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                 shape: const StadiumBorder(),
                 ),
              ),
             /* const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                  shape: const StadiumBorder(),
                  side: const BorderSide(color: Colors.green),
                ),
                child: const Text("Login", style: TextStyle(color: Colors.green)),
              ),
              */
              const SizedBox(height: 10),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/registerFarmacia');
                },
                child: Text("Quer adicionar os nossos servicos? Faça O seu registo"),
              )

            ],
          ),
        ],
      ),
    );
  }
}
