import 'package:flutter/material.dart';
import 'package:macos_ui/macos_ui.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure binding is initialized
  if (!kIsWeb) {
    if (Platform.isMacOS) {
      await _configureMacosWindowUtils();
    }
  }
  runApp(const MacosUIGalleryApp());
}

Future<void> _configureMacosWindowUtils() async {
  const config = MacosWindowUtilsConfig();
  await config.apply();
}

class MacosUIGalleryApp extends StatelessWidget {
  const MacosUIGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MacosApp(
      title: 'macOS Dock Example',
      themeMode: ThemeMode.light,
      debugShowCheckedModeBanner: false,
      home: const WidgetGallery(),
    );
  }
}

class WidgetGallery extends StatefulWidget {
  const WidgetGallery({super.key});

  @override
  State<WidgetGallery> createState() => _WidgetGalleryState();
}

class _WidgetGalleryState extends State<WidgetGallery> {
  int pageIndex = 0;
  final List<IconData> dockItems = [
    Icons.person,
    Icons.message,
    Icons.call,
    Icons.camera,
    Icons.photo,
  ];

  late final searchFieldController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MacosWindow(
      sidebar: Sidebar(
        top: MacosSearchField(
          placeholder: 'Search',
          controller: searchFieldController,
          onResultSelected: (result) {
            // Handle search result selection
          },
          results: const [
            SearchResultItem('Buttons'),
            SearchResultItem('Indicators'),
            // Add other search results here
          ],
        ),
        minWidth: 200,
        builder: (context, scrollController) {
          return SidebarItems(
            currentIndex: pageIndex,
            onChanged: (i) {
              setState(() => pageIndex = i);
            },
            scrollController: scrollController,
            itemSize: SidebarItemSize.large,
            items: const [
              SidebarItem(
                leading: MacosIcon(Icons.person),
                label: Text('Profile'),
              ),
              SidebarItem(
                leading: MacosIcon(Icons.mail),
                label: Text('Messages'),
              ),
              SidebarItem(
                leading: MacosIcon(Icons.phone),
                label: Text('Calls'),
              ),
              SidebarItem(
                leading: MacosIcon(Icons.camera),
                label: Text('Camera'),
              ),
              SidebarItem(
                leading: MacosIcon(Icons.photo),
                label: Text('Photos'),
              ),
            ],
          );
        },
      ),
      child: Stack(
        children: [
          // Main content
          _buildMainContent(),
          // Dock at the bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: 80,
            child: MacosDock(
              items: dockItems,
              builder: (icon) {
                return Container(
                  constraints: const BoxConstraints(minWidth: 48),
                  height: 48,
                  margin: const EdgeInsets.symmetric(horizontal: 4), // Reduced spacing between items
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.primaries[icon.hashCode % Colors.primaries.length],
                  ),
                  child: Center(child: Icon(icon, color: Colors.white)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return IndexedStack(
      index: pageIndex,
      children: [
        const Center(child: Text('Profile Page')),
        const Center(child: Text('Messages Page')),
        const Center(child: Text('Calls Page')),
        const Center(child: Text('Camera Page')),
        const Center(child: Text('Photos Page')),
      ],
    );
  }
}

class MacosDock extends StatefulWidget {
  const MacosDock({
    Key? key,
    required this.items,
    required this.builder,
  }) : super(key: key);

  final List<IconData> items; // List of icons for the dock
  final Widget Function(IconData) builder; // Builder function for each dock item

  @override
  State<MacosDock> createState() => _MacosDockState();
}

class _MacosDockState extends State<MacosDock> {
  late List<IconData> _dockItems;

  @override
  void initState() {
    super.initState();
    _dockItems = widget.items.toList(); // Initialize dock items
  }

  @override
  Widget build(BuildContext context) {
    return Center( // Center the dock in the available space
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black12,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min, // Use minimum size for the row
          children: List.generate(_dockItems.length, (index) {
            final icon = _dockItems[index];
            return Draggable<IconData>(
              data: icon,
              feedback: Material(
                color: Colors.transparent,
                child: Opacity(
                  opacity: 0.7,
                  child: widget.builder(icon), // Use the builder for feedback
                ),
              ),
              childWhenDragging: Container(), // Keep space when dragging
              child: DragTarget<IconData>(
                onWillAccept: (data) => data != icon, // Prevent dropping on itself
                onAccept: (data) {
                  setState(() {
                    // Find the index of the dragged item and the target item
                    final draggedIndex = _dockItems.indexOf(data);
                    // Move the item in the list
                    if (draggedIndex != -1 && draggedIndex != index) {
                      _dockItems.removeAt(draggedIndex);
                      _dockItems.insert(index, data);
                    }
                  });
                },
                builder: (context, candidateData, rejectedData) {
                  return widget.builder(icon); // Use the builder for the normal state
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}
