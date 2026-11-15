import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../core/color/color.dart';
import '../../../../core/dimensions/dimensions.dart';
import '../../../../core/session/account_session.dart';
import '../../../quests/presentation/pages/quests_page.dart';
import '../../../quests/data/repositories/parsed_quest_repository.dart';
import '../../../quests/domain/engines/quest_engine.dart';
import '../../../account/presentation/pages/account_page.dart';
import '../widgets/dashboard_bottom_nav.dart';
import '../widgets/dashboard_sidebar.dart';
import '../widgets/quest_section.dart';

class DashboardPage extends StatefulWidget {
  final int initialNavIndex;
  final AccountSession accountSession;

  const DashboardPage({
    super.key,
    this.initialNavIndex = 0,
    required this.accountSession,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  ParsedQuestRepository? _questRepository;
  QuestEngine? _questEngine;
  late int _currentNavIndex;

  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.initialNavIndex;
    _loadQuests();
  }

  Future<void> _loadQuests() async {
    try {
      // Repo live: pakai AccountSession supaya token Discord bisa dipakai
      // untuk memanggil GET /quests/@me saat engine dijalankan.
      final repository = ParsedQuestRepository(
        accountSession: widget.accountSession,
      );

      // Seed data fixture sebagai tampilan awal sebelum login / sebelum fetch.
      try {
        rootBundle.evict('assets/data/quests.json');
        final jsonString =
            await rootBundle.loadString('assets/data/quests.json');
        final rawData = jsonDecode(jsonString);
        repository.seedFromRawData(rawData);
      } catch (fixtureError) {
        // Fixture opsional; kalau tidak ada, lanjut dengan repo kosong.
        debugPrint('Fixture quests.json tidak termuat: $fixtureError');
      }

      if (!mounted) {
        repository.dispose();
        return;
      }

      final engine = QuestEngine(repository: repository)
        ..onLog = ((message, level) {
          debugPrint('[QuestEngine][$level] $message');
        });

      setState(() {
        _questRepository = repository;
        _questEngine = engine;
        _isLoading = false;
      });
    } catch (e, stackTrace) {
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _loadError = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _questEngine?.dispose();
    _questRepository?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.accountSession,
      builder: (context, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth >= 960;

            final username =
                widget.accountSession.accountInfo?.effectiveDisplayName ??
                'Guest';

            final questRepository = _questRepository;
            final questEngine = _questEngine;

            if (_isLoading) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (_loadError != null ||
                questRepository == null ||
                questEngine == null) {
              return Scaffold(
                body: Center(
                  child: Text(
                    'Gagal memuat quest: ${_loadError ?? "Repository tidak tersedia"}',
                  ),
                ),
              );
            }

            return Scaffold(
              backgroundColor: AppColor.background,
              bottomNavigationBar: isDesktop
                  ? null
                  : DashboardBottomNav(
                      currentIndex: _currentNavIndex,
                      onTap: (index) {
                        setState(() => _currentNavIndex = index);
                      },
                    ),
              body: Row(
                children: [
                  if (isDesktop)
                    DashboardSidebar(
                      accountSession: widget.accountSession,
                      selectedIndex: _currentNavIndex,
                      onDestinationSelected: (index) {
                        setState(() => _currentNavIndex = index);
                      },
                    ),

                  Expanded(
                    child: _currentNavIndex == 1
                        ? QuestsPage(
                            repository: questRepository,
                            engine: questEngine,
                            embedded: true,
                            onNavigate: (index) {
                              setState(() => _currentNavIndex = index);
                            },
                          )
                        : _currentNavIndex == 5
                        ? AccountPage(accountSession: widget.accountSession)
                        : SafeArea(
                            child: SingleChildScrollView(
                              padding: EdgeInsets.symmetric(
                                horizontal: isDesktop
                                    ? AppSpacing.xl
                                    : AppSpacing.md,
                                vertical: AppSpacing.lg,
                              ),
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 1100,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Dashboard',
                                        style: const TextStyle(
                                          color: AppColor.textPrimary,
                                          fontSize: 28,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),

                                      const SizedBox(height: AppSpacing.xs),

                                      Text(
                                        'Welcome back, $username!',
                                        style: const TextStyle(
                                          color: AppColor.textSecondary,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),

                                      const SizedBox(height: AppSpacing.md),

                                      // ── Automation control ─────────────
                                      Row(
                                        children: [
                                          FilledButton.icon(
                                            onPressed: () {
                                              final engine = _questEngine;
                                              if (engine == null) return;
                                              if (engine.isRunning) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                      'Automation sedang berjalan.',
                                                    ),
                                                  ),
                                                );
                                                return;
                                              }
                                              engine.startAutomation();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Automation dimulai. Cek konsol untuk log.',
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: const Icon(
                                              Icons.play_arrow_rounded,
                                            ),
                                            label: const Text(
                                              'Start Automation',
                                            ),
                                          ),
                                          const SizedBox(width: AppSpacing.sm),
                                          OutlinedButton.icon(
                                            onPressed: () {
                                              _questEngine?.stop();
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Automation dihentikan.',
                                                  ),
                                                ),
                                              );
                                            },
                                            icon: const Icon(Icons.stop_rounded),
                                            label: const Text('Stop'),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: AppSpacing.xxl),

                                      QuestSection(
                                        repository: questRepository,
                                        onViewAll: () {
                                          setState(() {
                                            _currentNavIndex = 1;
                                          });
                                        },
                                      ),

                                      const SizedBox(height: AppSpacing.xxl),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
