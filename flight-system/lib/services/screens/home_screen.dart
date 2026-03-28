import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _Sidebar(),
      appBar: AppBar(
        title: const Text('Find your next flight'),
        actions: [TextButton(onPressed: ()=>Navigator.pushNamed(context, '/search'), child: const Text('Start booking'))],
      ),
      body: ListView(
        children: [
          _HeroHeader(),
          const Padding(padding: EdgeInsets.all(16), child: Text('Popular routes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
          _RouteGrid(),
        ],
      ),
    );
  }
}

class _HeroHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Image.asset('assets/hero.jpg', height: 220, width: double.infinity, fit: BoxFit.cover),
      Container(height: 220, decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [Color(0x880A0F2D), Color(0xAA0A0F2D)], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
      Positioned.fill(child: Center(child: Column(mainAxisSize: MainAxisSize.min, children: const [
        Text('Find your next flight', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        SizedBox(height: 6),
        Text('Best deals, flexible dates, and a smooth booking experience.', style: TextStyle(color: Colors.white70)),
      ]))),
    ]);
  }
}

class _RouteGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cards = [
      _FlightCard('MAA → BLR', 'Non-stop • 1h 5m • SAS 210', 'Economy from ₹2799'),
      _FlightCard('MAA → DEL', '1 stop • 3h 20m • SAS 514', 'Business from ₹8999'),
      _FlightCard('MAA → BOM', 'Non-stop • 2h • SAS 332', 'Economy from ₹3299'),
    ];
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2, childAspectRatio: 1.4, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        children: cards,
      ),
    );
  }
}

class _FlightCard extends StatelessWidget {
  final String title, subtitle, pill;
  const _FlightCard(this.title, this.subtitle, this.pill);
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2, clipBehavior: Clip.hardEdge,
      child: InkWell(
        onTap: ()=>Navigator.pushNamed(context, '/search'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(height: 70, decoration: const BoxDecoration(
              gradient: LinearGradient(colors: [Color(0xFF4F8CFF), Color(0xFF7C5CFF), Color(0xFFFF4F6A)], begin: Alignment.topLeft, end: Alignment.bottomRight))),
            const SizedBox(height: 8),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: const Color(0xFFF1F5FF), borderRadius: BorderRadius.circular(999)),
                child: Text(pill, style: const TextStyle(fontSize: 11)))
            ]),
            const SizedBox(height: 6),
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
            const Spacer(),
            Row(children: [
              OutlinedButton(onPressed: ()=>Navigator.pushNamed(context, '/search'), child: const Text('Details')),
              const SizedBox(width: 8),
              ElevatedButton(onPressed: ()=>Navigator.pushNamed(context, '/search'), child: const Text('Book')),
            ])
          ]),
        ),
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(child: ListView(children: [
      DrawerHeader(child: Row(children: [
        SvgPicture.asset('assets/logo.svg', height: 40), const SizedBox(width: 12), const Text('SASTHA', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
      ])),
      ListTile(title: const Text('Home'), onTap: ()=>Navigator.pushNamed(context, '/')),
      ListTile(title: const Text('Booking'), onTap: ()=>Navigator.pushNamed(context, '/search')),
      ListTile(title: const Text('Dashboard'), onTap: ()=>Navigator.pushNamed(context, '/admin')),
      ListTile(title: const Text('Boarding Pass'), onTap: ()=>Navigator.pushNamed(context, '/qr')),
    ]));
  }
}