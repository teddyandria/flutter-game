// lib/components/ui/inventory_overlay.dart
import 'package:flutter/material.dart';
import 'package:bonfire/bonfire.dart';
import 'package:app/components/knight.dart';
// ⚠️ Adapte ce chemin à ton arborescence réelle.
// Si ton fichier est à lib/inventory/inventory.dart, utilise :
import 'package:app/components/inventory/inventory.dart';

class InventoryOverlay extends StatefulWidget {
  final BonfireGame game;
  const InventoryOverlay({super.key, required this.game});

  @override
  State<InventoryOverlay> createState() => _InventoryOverlayState();
}

class _InventoryOverlayState extends State<InventoryOverlay> {
  Knight? _player;
  VoidCallback? _invListener;

  @override
  void initState() {
    super.initState();
    // On attend que le player soit dispo dans le game
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = widget.game.player;
      if (p is Knight) {
        _attachToPlayer(p);
        setState(() {}); // premier build avec les données
      }
    });
  }

  void _attachToPlayer(Knight p) {
    // Si on était déjà abonné, on nettoie
    if (_player != null && _invListener != null) {
      _player!.inventory.removeListener(_invListener!);
    }
    _player = p;
    _invListener = () => setState(() {});
    p.inventory.addListener(_invListener!);
  }

  @override
  void dispose() {
    if (_player != null && _invListener != null) {
      _player!.inventory.removeListener(_invListener!);
    }
    super.dispose();
  }

  String _itemLabel(Item it) {
    if (it.type == 'key') {
      switch (it.id) {
        case 'key_gold':
          return 'Clé or';
        case 'key_blue':
          return 'Clé bleue';
        case 'key_green':
          return 'Clé verte';
        default:
          return 'Clé';
      }
    }
    return it.id;
  }

  @override
  Widget build(BuildContext context) {
    final player = _player;
    final List<Item> items = (player == null) ? <Item>[] : player.inventory.items;

    return SafeArea(
      child: Align(
        alignment: Alignment.topRight, // change ici pour déplacer l'overlay
        child: Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white24),
          ),
          child: items.isEmpty
              ? const Text('Inventaire vide', style: TextStyle(color: Colors.white))
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: items.map((it) {
                    final isKey = it.type == 'key';
                    return Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isKey ? Colors.amber.withOpacity(0.2) : Colors.white10,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isKey ? Icons.vpn_key : Icons.inventory_2,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '${_itemLabel(it)} x${it.quantity}',
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ),
    );
  }
}
