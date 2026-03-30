import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/api_service.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/chat_provider.dart';
import '../../widgets/modern_app_bar.dart';

class ConsultationScreen extends StatelessWidget {
  final String? preselectedServiceId;

  const ConsultationScreen({super.key, this.preselectedServiceId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ModernAppBar(
        title: 'Nouvelle Consultation',
        leading: ModernAppBarAction(
          icon: Icons.arrow_back_ios_new,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ConsultationBody(preselectedServiceId: preselectedServiceId),
    );
  }
}

class ConsultationBody extends StatefulWidget {
  final String? preselectedServiceId;

  const ConsultationBody({super.key, this.preselectedServiceId});

  @override
  State<ConsultationBody> createState() => _ConsultationBodyState();
}

class _ConsultationBodyState extends State<ConsultationBody> {
  int _currentStep = 0;
  int _previousStep = 0;
  String? _selectedService;
  bool _isSubmitting = false;

  // ── Shared controllers ──────────────────────────────────────────────────
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _townController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  String? _selectedPaymentMethod;

  // ── Investor (real_estate) ──────────────────────────────────────────────
  final TextEditingController _investmentInterestController =
      TextEditingController();
  String? _budgetRange;
  String? _projectType;
  bool _ndaAccepted = false;

  // ── Enterprise (business) ──────────────────────────────────────────────
  final TextEditingController _companyNameController = TextEditingController();
  String? _companySize;
  final TextEditingController _sectorController = TextEditingController();
  final TextEditingController _stakesController = TextEditingController();
  String? _businessBudgetRange;

  // ── Football (foot) ────────────────────────────────────────────────────
  final TextEditingController _playerNameController = TextEditingController();
  final TextEditingController _currentClubController = TextEditingController();
  String? _playerPosition;
  final TextEditingController _transfermarktController = TextEditingController();
  final TextEditingController _highlightVideoController =
      TextEditingController();
  final TextEditingController _contractHistoryController =
      TextEditingController();

  // ── Charity ────────────────────────────────────────────────────────────
  final TextEditingController _charityProjectController =
      TextEditingController();
  String? _impactArea;

  // ── Service catalog ────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _services = [
    {
      'id': 'foot',
      'title': 'Football',
      'description': 'Gestion de carrière & conseils',
      'price': '100,000 FCFA',
      'accent': const Color(0xFF1565C0),
      'image':
          'https://images.unsplash.com/photo-1574629810360-7efbbe195018?auto=format&fit=crop&q=80&w=600',
    },
    {
      'id': 'real_estate',
      'title': 'Immobilier',
      'description': 'Investissement & Construction',
      'price': '150,000 FCFA',
      'accent': const Color(0xFFD4AF37),
      'image':
          'https://images.unsplash.com/photo-1512917774080-9991f1c4c750?auto=format&fit=crop&q=80&w=600',
    },
    {
      'id': 'business',
      'title': 'Business',
      'description': 'Stratégie & Développement',
      'price': '200,000 FCFA',
      'accent': const Color(0xFF7B1FA2),
      'image':
          'https://images.unsplash.com/photo-1553877522-43269d4ea984?auto=format&fit=crop&q=80&w=600',
    },
    {
      'id': 'charity',
      'title': 'Philanthropie',
      'description': 'Actions sociales & Fondation',
      'price': 'Gratuit',
      'accent': const Color(0xFF2E7D32),
      'image':
          'https://images.unsplash.com/photo-1469571486292-0ba58a3f068b?auto=format&fit=crop&q=80&w=600',
    },
  ];

  // ── Per-service step flows ─────────────────────────────────────────────
  static const Map<String, List<Map<String, String>>> _serviceFlows = {
    'real_estate': [
      {
        'id': 'project_investor',
        'title': 'Projet',
        'subtitle': 'Investissement'
      },
      {'id': 'kyc_investor', 'title': 'Vérification', 'subtitle': 'KYC'},
      {'id': 'engagement', 'title': 'Engagement', 'subtitle': 'NDA'},
      {'id': 'payment', 'title': 'Paiement', 'subtitle': 'Final'},
    ],
    'business': [
      {
        'id': 'qualification',
        'title': 'Qualification',
        'subtitle': 'Entreprise'
      },
      {'id': 'kyc_standard', 'title': 'Identité', 'subtitle': 'KYC'},
      {
        'id': 'review_business',
        'title': 'Récapitulatif',
        'subtitle': 'Vérification'
      },
      {'id': 'payment', 'title': 'Paiement', 'subtitle': 'Final'},
    ],
    'foot': [
      {'id': 'dossier', 'title': 'Dossier', 'subtitle': 'Joueur'},
      {'id': 'kyc_standard', 'title': 'Identité', 'subtitle': 'KYC'},
      {'id': 'submission', 'title': 'Soumission', 'subtitle': 'Envoi'},
    ],
    'charity': [
      {
        'id': 'project_charity',
        'title': 'Projet',
        'subtitle': 'Philanthropie'
      },
      {'id': 'kyc_standard', 'title': 'Identité', 'subtitle': 'KYC'},
      {'id': 'confirmation', 'title': 'Confirmation', 'subtitle': 'Envoi'},
    ],
  };

  // ── Fallback step labels (before service is selected) ──────────────────
  static const List<Map<String, String>> _defaultStepLabels = [
    {'title': 'Service', 'subtitle': 'Choix'},
    {'title': 'Détails', 'subtitle': '...'},
    {'title': 'Identité', 'subtitle': 'KYC'},
    {'title': 'Final', 'subtitle': '...'},
  ];

  // ── Dropdown options ───────────────────────────────────────────────────
  static const List<String> _budgetRanges = [
    'Moins de 50M FCFA',
    '50M – 200M FCFA',
    '200M – 500M FCFA',
    '500M – 1Md FCFA',
    'Plus de 1Md FCFA',
  ];

  static const List<String> _projectTypes = [
    'Résidentiel',
    'Commercial',
    'Infrastructure',
    'Mixte',
  ];

  static const List<String> _companySizes = [
    'PME',
    'ETI',
    'Grande Entreprise',
    'Institution',
  ];

  static const List<String> _playerPositions = [
    'Gardien',
    'Défenseur Central',
    'Latéral',
    'Milieu Défensif',
    'Milieu Central',
    'Milieu Offensif',
    'Ailier',
    'Attaquant',
  ];

  static const List<String> _impactAreas = [
    'Éducation',
    'Santé',
    'Sport',
    'Environnement',
    'Autre',
  ];

  // ── Computed navigation helpers ────────────────────────────────────────

  bool get _showServiceSelection => widget.preselectedServiceId == null;

  List<Map<String, String>> get _activeSteps {
    if (_selectedService == null) return _defaultStepLabels;
    return _serviceFlows[_selectedService] ?? _defaultStepLabels;
  }

  int get _totalSteps => _activeSteps.length;

  /// Index into _activeSteps. Returns -1 when on service selection.
  int get _flowStepIndex =>
      _showServiceSelection ? _currentStep - 1 : _currentStep;

  bool get _flowHasPayment =>
      _activeSteps.isNotEmpty && _activeSteps.last['id'] == 'payment';

  String get _continueButtonLabel {
    if (_flowStepIndex < 0) return 'SUIVANT';
    final isLastStep = _flowStepIndex == _totalSteps - 1;
    if (!isLastStep) return 'SUIVANT';
    final stepId = _activeSteps[_flowStepIndex]['id']!;
    switch (stepId) {
      case 'payment':
        return 'PAYER & FINALISER';
      case 'submission':
        return 'SOUMETTRE LE DOSSIER';
      case 'confirmation':
        return 'CONFIRMER & ENVOYER';
      default:
        return 'FINALISER';
    }
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    if (widget.preselectedServiceId != null) {
      _selectedService = widget.preselectedServiceId;
      _currentStep = 0; // flow step 0 directly
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        _nameController.text = user.name;
        _emailController.text = user.email;
        if (user.phone != null) _phoneController.text = user.phone!;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _townController.dispose();
    _countryController.dispose();
    _investmentInterestController.dispose();
    _companyNameController.dispose();
    _sectorController.dispose();
    _stakesController.dispose();
    _playerNameController.dispose();
    _currentClubController.dispose();
    _transfermarktController.dispose();
    _highlightVideoController.dispose();
    _contractHistoryController.dispose();
    _charityProjectController.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_flowStepIndex >= 0) _buildStepIndicator(),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 350),
            switchInCurve: Curves.easeOut,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, animation) {
              final isForward = _currentStep >= _previousStep;
              final slideOffset = Tween<Offset>(
                begin: Offset(isForward ? 0.15 : -0.15, 0),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: slideOffset, child: child),
              );
            },
            child: SingleChildScrollView(
              key: ValueKey<int>(_currentStep),
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                children: [
                  _buildStepContent(),
                  const SizedBox(height: 24),
                  _buildNavigationButtons(),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Step Indicator ─────────────────────────────────────────────────────

  Widget _buildStepIndicator() {
    final steps = _activeSteps;
    final activeIndex = _flowStepIndex;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(steps.length * 2 - 1, (index) {
          if (index.isOdd) {
            final stepBefore = index ~/ 2;
            final isCompleted = activeIndex > stepBefore;
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                color:
                    isCompleted ? AppTheme.primaryBlue : AppTheme.dividerDark,
              ),
            );
          }
          final stepIndex = index ~/ 2;
          final isActive = activeIndex >= stepIndex;
          final isComplete = activeIndex > stepIndex;
          final isCurrent = activeIndex == stepIndex;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeInOut,
                width: isCurrent ? 36 : 32,
                height: isCurrent ? 36 : 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isComplete || isCurrent
                      ? AppTheme.primaryBlue
                      : AppTheme.dividerDark,
                  boxShadow: isCurrent
                      ? [
                          BoxShadow(
                            color:
                                AppTheme.primaryBlue.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isComplete
                        ? const Icon(Icons.check,
                            color: Colors.white,
                            size: 18,
                            key: ValueKey('check'))
                        : Text(
                            '${stepIndex + 1}',
                            key: ValueKey('num_$stepIndex'),
                            style: TextStyle(
                              color: isCurrent
                                  ? Colors.white
                                  : AppTheme.textMuted,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight:
                      isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive ? Colors.white : AppTheme.textMuted,
                  fontFamily:
                      Theme.of(context).textTheme.bodyMedium?.fontFamily,
                ),
                child: Text(steps[stepIndex]['title']!),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ── Step Content Router ────────────────────────────────────────────────

  Widget _buildStepContent() {
    if (_flowStepIndex < 0) return _buildServiceContent();

    final stepId = _activeSteps[_flowStepIndex]['id']!;
    switch (stepId) {
      case 'kyc_standard':
        return _buildKycContent();
      case 'payment':
        return _buildPaymentContent();
      case 'project_investor':
        return _buildInvestorProjectContent();
      case 'kyc_investor':
        return _buildInvestorKycContent();
      case 'engagement':
        return _buildEngagementContent();
      case 'qualification':
        return _buildQualificationContent();
      case 'review_business':
        return _buildReviewBusinessContent();
      case 'dossier':
        return _buildDossierContent();
      case 'submission':
        return _buildSubmissionContent();
      case 'project_charity':
        return _buildCharityProjectContent();
      case 'confirmation':
        return _buildConfirmationContent();
      default:
        return const SizedBox.shrink();
    }
  }

  // ── Navigation Buttons ─────────────────────────────────────────────────

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: _isSubmitting
                  ? null
                  : () => setState(() {
                        _previousStep = _currentStep;
                        _currentStep -= 1;
                      }),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: AppTheme.gold.withValues(alpha: 0.5)),
              ),
              child: const Text('RETOUR'),
            ),
          ),
          const SizedBox(width: 16),
        ],
        Expanded(
          child: ElevatedButton(
            onPressed: _isSubmitting ? null : _handleStepContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.gold,
              foregroundColor: AppTheme.obsidian,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    _continueButtonLabel,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
          ),
        ),
      ],
    );
  }

  // ── Validation & Navigation Logic ──────────────────────────────────────

  Future<void> _handleStepContinue() async {
    // Service selection step
    if (_flowStepIndex < 0) {
      if (_selectedService == null) {
        _showError('Veuillez sélectionner un type de service.');
        return;
      }
      setState(() {
        _previousStep = _currentStep;
        _currentStep += 1;
      });
      return;
    }

    final stepId = _activeSteps[_flowStepIndex]['id']!;
    final error = _validateStep(stepId);
    if (error != null) {
      _showError(error);
      return;
    }

    final isLastStep = _flowStepIndex == _totalSteps - 1;
    if (!isLastStep) {
      setState(() {
        _previousStep = _currentStep;
        _currentStep += 1;
      });
    } else {
      await _submitConsultation();
    }
  }

  String? _validateStep(String stepId) {
    switch (stepId) {
      case 'kyc_standard':
      case 'kyc_investor':
        if (_nameController.text.isEmpty ||
            _phoneController.text.isEmpty ||
            _emailController.text.isEmpty ||
            _townController.text.isEmpty ||
            _countryController.text.isEmpty) {
          return 'Veuillez remplir toutes vos informations.';
        }
        final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
        if (!emailRegex.hasMatch(_emailController.text.trim())) {
          return 'Veuillez saisir une adresse e-mail valide.';
        }
        return null;

      case 'payment':
        if (_selectedPaymentMethod == null) {
          return 'Veuillez choisir un mode de paiement.';
        }
        return null;

      case 'project_investor':
        if (_investmentInterestController.text.trim().length < 20) {
          return 'Veuillez décrire votre projet (min. 20 caractères).';
        }
        if (_budgetRange == null) {
          return 'Veuillez sélectionner une tranche de budget.';
        }
        if (_projectType == null) {
          return 'Veuillez sélectionner un type de projet.';
        }
        return null;

      case 'engagement':
        if (!_ndaAccepted) {
          return "Veuillez accepter l'accord de confidentialité.";
        }
        return null;

      case 'qualification':
        if (_companyNameController.text.trim().isEmpty) {
          return "Veuillez saisir le nom de l'entreprise.";
        }
        if (_companySize == null) {
          return "Veuillez sélectionner la taille de l'entreprise.";
        }
        if (_sectorController.text.trim().isEmpty) {
          return "Veuillez indiquer le secteur d'activité.";
        }
        if (_stakesController.text.trim().length < 20) {
          return 'Veuillez décrire vos enjeux (min. 20 caractères).';
        }
        if (_businessBudgetRange == null) {
          return 'Veuillez sélectionner une tranche de budget.';
        }
        return null;

      case 'dossier':
        if (_playerNameController.text.trim().isEmpty) {
          return 'Veuillez saisir le nom du joueur.';
        }
        if (_currentClubController.text.trim().isEmpty) {
          return 'Veuillez indiquer le club actuel.';
        }
        if (_playerPosition == null) {
          return 'Veuillez sélectionner un poste.';
        }
        return null;

      case 'project_charity':
        if (_charityProjectController.text.trim().length < 20) {
          return 'Veuillez décrire votre projet (min. 20 caractères).';
        }
        if (_impactArea == null) {
          return "Veuillez sélectionner un domaine d'impact.";
        }
        return null;

      case 'review_business':
      case 'submission':
      case 'confirmation':
        return null;

      default:
        return null;
    }
  }

  // ── Submission ─────────────────────────────────────────────────────────

  Future<void> _submitConsultation() async {
    setState(() => _isSubmitting = true);
    try {
      final token = context.read<AuthProvider>().token;
      final api = ApiService(token: token);

      final payload = <String, dynamic>{
        'service': _selectedService,
        'subject': _buildSubjectForPayload(),
        'kyc': {
          'name': _nameController.text.trim(),
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'city': _townController.text.trim(),
          'country': _countryController.text.trim(),
        },
        'details': _buildServiceDetails(),
      };

      if (_flowHasPayment) {
        payload['paymentMethod'] = _selectedPaymentMethod;
      }

      final result =
          await api.post('/consultations', payload) as Map<String, dynamic>;

      if (mounted) {
        await context.read<ChatProvider>().getOrCreateConversation(
              subject: _getServiceTitle(_selectedService),
              consultationId: result['_id']?.toString(),
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Demande envoyée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _buildSubjectForPayload() {
    switch (_selectedService) {
      case 'real_estate':
        return _investmentInterestController.text.trim();
      case 'business':
        return _stakesController.text.trim();
      case 'foot':
        final name = _playerNameController.text.trim();
        final club = _currentClubController.text.trim();
        return 'Dossier: $name – $club';
      case 'charity':
        return _charityProjectController.text.trim();
      default:
        return '';
    }
  }

  Map<String, dynamic> _buildServiceDetails() {
    switch (_selectedService) {
      case 'real_estate':
        return {
          'investmentInterest': _investmentInterestController.text.trim(),
          'budgetRange': _budgetRange,
          'projectType': _projectType,
          'ndaAccepted': _ndaAccepted,
        };
      case 'business':
        return {
          'companyName': _companyNameController.text.trim(),
          'companySize': _companySize,
          'sector': _sectorController.text.trim(),
          'stakes': _stakesController.text.trim(),
          'budgetRange': _businessBudgetRange,
        };
      case 'foot':
        return {
          'playerName': _playerNameController.text.trim(),
          'currentClub': _currentClubController.text.trim(),
          'position': _playerPosition,
          'transfermarktLink': _transfermarktController.text.trim(),
          'highlightVideoLink': _highlightVideoController.text.trim(),
          'contractHistory': _contractHistoryController.text.trim(),
        };
      case 'charity':
        return {
          'project': _charityProjectController.text.trim(),
          'impactArea': _impactArea,
        };
      default:
        return {};
    }
  }

  String _getServiceTitle(String? serviceId) {
    final svc = _services.firstWhere(
      (s) => s['id'] == serviceId,
      orElse: () => {'title': 'Consultation'},
    );
    return svc['title'] as String;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  SHARED UI HELPERS
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    IconData? prefixIcon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? hintText,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        counterText: maxLength != null ? null : '',
        counterStyle:
            const TextStyle(color: AppTheme.textMuted, fontSize: 11),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: AppTheme.surface,
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppTheme.dividerDark)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppTheme.gold, width: 2)),
        labelStyle: const TextStyle(color: AppTheme.textMuted),
        prefixIconColor: AppTheme.textMuted,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    IconData icon = Icons.arrow_drop_down_circle_outlined,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
      dropdownColor: AppTheme.surface,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: AppTheme.surface,
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppTheme.dividerDark)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: AppTheme.gold, width: 2)),
        labelStyle: const TextStyle(color: AppTheme.textMuted),
        prefixIconColor: AppTheme.textMuted,
      ),
    );
  }

  Widget _buildUploadSection({
    required IconData icon,
    required String title,
    required String description,
    required String buttonLabel,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.gold.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.gold.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.gold),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.goldLight),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style:
                const TextStyle(fontSize: 13, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => AppTheme.showComingSoon(context),
              icon: const Icon(Icons.upload_file),
              label: Text(buttonLabel),
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.dividerDark),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(value,
                style:
                    const TextStyle(color: Colors.white, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  /// Shared KYC fields returned as a list for reuse.
  List<Widget> _buildKycFields() {
    return [
      _buildStyledTextField(
        controller: _nameController,
        label: 'Nom Complet / Entreprise',
        prefixIcon: Icons.person_outline,
        maxLength: 100,
      ),
      const SizedBox(height: 16),
      _buildStyledTextField(
        controller: _phoneController,
        label: 'Numéro de Téléphone',
        prefixIcon: Icons.phone_outlined,
        keyboardType: TextInputType.phone,
        maxLength: 20,
      ),
      const SizedBox(height: 16),
      _buildStyledTextField(
        controller: _emailController,
        label: 'Adresse Email',
        prefixIcon: Icons.email_outlined,
        keyboardType: TextInputType.emailAddress,
        maxLength: 100,
      ),
      const SizedBox(height: 16),
      Row(
        children: [
          Expanded(
            child: _buildStyledTextField(
              controller: _townController,
              label: 'Ville',
              prefixIcon: Icons.location_city,
              maxLength: 60,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStyledTextField(
              controller: _countryController,
              label: 'Pays',
              prefixIcon: Icons.flag_outlined,
              maxLength: 60,
            ),
          ),
        ],
      ),
    ];
  }

  // ══════════════════════════════════════════════════════════════════════════
  //  STEP CONTENT BUILDERS
  // ══════════════════════════════════════════════════════════════════════════

  // ── Step 0: Service Selection ──────────────────────────────────────────

  Widget _buildServiceContent() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _services.length,
      separatorBuilder: (_, _) => const SizedBox(height: 16),
      itemBuilder: (_, index) {
        final service = _services[index];
        final isSelected = _selectedService == service['id'];
        final Color accent = service['accent'] as Color;
        return GestureDetector(
          onTap: () {
            setState(() => _selectedService = service['id'] as String);
            _handleStepContinue();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: isSelected
                  ? Border.all(color: accent, width: 3)
                  : Border.all(color: Colors.transparent, width: 3),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: isSelected ? 0.2 : 0.08),
                  blurRadius: isSelected ? 20 : 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(21),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    service['image'] as String,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: accent.withValues(alpha: 0.15),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topRight,
                        end: Alignment.bottomLeft,
                        colors: [
                          Colors.black.withValues(alpha: 0.1),
                          Colors.black.withValues(alpha: 0.65),
                          Colors.black.withValues(alpha: 0.85),
                        ],
                        stops: const [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            service['price'] as String,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: accent),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          service['title'] as String,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          service['description'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Positioned(
                      top: 16,
                      right: 16,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                            color: accent, shape: BoxShape.circle),
                        child: const Icon(Icons.check,
                            color: Colors.white, size: 16),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ── Shared: KYC Step ───────────────────────────────────────────────────

  Widget _buildKycContent() {
    return Column(
      children: [
        ..._buildKycFields(),
        const SizedBox(height: 24),
        _buildUploadSection(
          icon: Icons.shield_outlined,
          title: "Vérification d'Identité (KYC)",
          description:
              "Conformément à nos procédures, une pièce d'identité est requise pour valider votre dossier.",
          buttonLabel: 'Télécharger CNI / Passeport',
        ),
      ],
    );
  }

  // ── Shared: Payment Step ───────────────────────────────────────────────

  Widget _buildPaymentContent() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total à payer',
                style: TextStyle(fontSize: 16, color: AppTheme.textMuted),
              ),
              Text(
                _selectedService != null
                    ? _services.firstWhere(
                        (s) => s['id'] == _selectedService,
                      )['price'] as String
                    : '0 FCFA',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.gold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _PaymentMethodItem(
          id: 'om',
          name: 'Orange Money',
          icon: Icons.wallet,
          color: Colors.orange,
          groupValue: _selectedPaymentMethod,
          onChanged: (v) => setState(() => _selectedPaymentMethod = v),
        ),
        const SizedBox(height: 12),
        _PaymentMethodItem(
          id: 'momo',
          name: 'MTN Mobile Money',
          icon: Icons.mobile_screen_share,
          color: Colors.yellow[700]!,
          groupValue: _selectedPaymentMethod,
          onChanged: (v) => setState(() => _selectedPaymentMethod = v),
        ),
        const SizedBox(height: 12),
        _PaymentMethodItem(
          id: 'card',
          name: 'Carte Bancaire',
          icon: Icons.credit_card,
          color: AppTheme.primaryBlue,
          groupValue: _selectedPaymentMethod,
          onChanged: (v) => setState(() => _selectedPaymentMethod = v),
        ),
      ],
    );
  }

  // ── Path A: Investor – Project Step ────────────────────────────────────

  Widget _buildInvestorProjectContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Décrivez votre intérêt d'investissement",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        _buildStyledTextField(
          controller: _investmentInterestController,
          label: "Description du projet",
          hintText:
              'Nature du projet, objectifs, localisation souhaitée...',
          maxLines: 4,
          maxLength: 1000,
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Budget estimé',
          value: _budgetRange,
          items: _budgetRanges,
          onChanged: (v) => setState(() => _budgetRange = v),
          icon: Icons.account_balance_wallet_outlined,
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Type de projet',
          value: _projectType,
          items: _projectTypes,
          onChanged: (v) => setState(() => _projectType = v),
          icon: Icons.domain_outlined,
        ),
      ],
    );
  }

  // ── Path A: Investor – KYC Step ────────────────────────────────────────

  Widget _buildInvestorKycContent() {
    return Column(
      children: [
        ..._buildKycFields(),
        const SizedBox(height: 24),
        _buildUploadSection(
          icon: Icons.shield_outlined,
          title: "Vérification d'Identité (KYC)",
          description:
              "Conformément à nos procédures, une pièce d'identité est requise pour valider votre dossier.",
          buttonLabel: 'Télécharger CNI / Passeport',
        ),
        const SizedBox(height: 16),
        _buildUploadSection(
          icon: Icons.account_balance_wallet_outlined,
          title: 'Preuve de fonds',
          description:
              "Un justificatif de capacité financière est requis pour les investissements.",
          buttonLabel: 'Télécharger justificatif',
        ),
      ],
    );
  }

  // ── Path A: Investor – Engagement/NDA Step ─────────────────────────────

  Widget _buildEngagementContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Accord de Confidentialité',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: AppTheme.gold.withValues(alpha: 0.3)),
          ),
          child: const Text(
            'En soumettant cette demande, vous reconnaissez que toutes les informations '
            'échangées dans le cadre de cette consultation sont strictement confidentielles. '
            'Vous vous engagez à ne pas divulguer, reproduire ou utiliser ces informations '
            'à des fins autres que celles convenues avec MBIA Consulting.\n\n'
            'Un accord de non-divulgation (NDA) formel vous sera présenté '
            'pour signature électronique dans une étape ultérieure.',
            style: TextStyle(
                color: AppTheme.textMuted, fontSize: 14, height: 1.6),
          ),
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => setState(() => _ndaAccepted = !_ndaAccepted),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _ndaAccepted,
                  onChanged: (v) =>
                      setState(() => _ndaAccepted = v ?? false),
                  activeColor: AppTheme.gold,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4)),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "J'accepte les termes de l'accord de confidentialité "
                  "et je souhaite signifier mon intérêt pour ce projet.",
                  style: TextStyle(
                      color: Colors.white, fontSize: 14, height: 1.4),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.gold.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.gold, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'La signature électronique du NDA complet sera disponible prochainement.',
                  style:
                      TextStyle(color: AppTheme.goldLight, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Path B: Enterprise – Qualification Step ────────────────────────────

  Widget _buildQualificationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Qualifiez votre entreprise",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        _buildStyledTextField(
          controller: _companyNameController,
          label: "Nom de l'entreprise",
          prefixIcon: Icons.business_outlined,
          maxLength: 100,
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: "Taille de l'entreprise",
          value: _companySize,
          items: _companySizes,
          onChanged: (v) => setState(() => _companySize = v),
          icon: Icons.groups_outlined,
        ),
        const SizedBox(height: 16),
        _buildStyledTextField(
          controller: _sectorController,
          label: "Secteur d'activité",
          prefixIcon: Icons.category_outlined,
          maxLength: 100,
        ),
        const SizedBox(height: 16),
        _buildStyledTextField(
          controller: _stakesController,
          label: 'Enjeux & Besoins',
          hintText:
              'Décrivez vos enjeux stratégiques et le contexte de votre demande...',
          maxLines: 4,
          maxLength: 1000,
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Budget estimé (Provision)',
          value: _businessBudgetRange,
          items: _budgetRanges,
          onChanged: (v) => setState(() => _businessBudgetRange = v),
          icon: Icons.account_balance_wallet_outlined,
        ),
      ],
    );
  }

  // ── Path B: Enterprise – Review Step ──────────────────────────────────

  Widget _buildReviewBusinessContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Récapitulatif de votre demande',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        _buildReviewCard('Entreprise', _companyNameController.text),
        _buildReviewCard('Taille', _companySize ?? ''),
        _buildReviewCard("Secteur d'activité", _sectorController.text),
        _buildReviewCard('Enjeux & Besoins', _stakesController.text),
        _buildReviewCard('Budget estimé', _businessBudgetRange ?? ''),
        _buildReviewCard('Contact', _emailController.text),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.gold.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            children: [
              Icon(Icons.info_outline, color: AppTheme.gold, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Vérifiez vos informations avant de procéder au paiement.',
                  style:
                      TextStyle(color: AppTheme.goldLight, fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Path C: Football – Dossier Step ────────────────────────────────────

  Widget _buildDossierContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Dossier d'admission",
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        _buildStyledTextField(
          controller: _playerNameController,
          label: 'Nom du joueur',
          prefixIcon: Icons.person_outline,
          maxLength: 100,
        ),
        const SizedBox(height: 16),
        _buildStyledTextField(
          controller: _currentClubController,
          label: 'Club actuel',
          prefixIcon: Icons.sports_soccer_outlined,
          maxLength: 100,
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: 'Poste',
          value: _playerPosition,
          items: _playerPositions,
          onChanged: (v) => setState(() => _playerPosition = v),
          icon: Icons.sports_outlined,
        ),
        const SizedBox(height: 16),
        _buildStyledTextField(
          controller: _transfermarktController,
          label: 'Lien Transfermarkt',
          prefixIcon: Icons.link_outlined,
          keyboardType: TextInputType.url,
          maxLength: 500,
        ),
        const SizedBox(height: 16),
        _buildStyledTextField(
          controller: _highlightVideoController,
          label: 'Lien vidéo highlights',
          prefixIcon: Icons.videocam_outlined,
          keyboardType: TextInputType.url,
          maxLength: 500,
        ),
        const SizedBox(height: 16),
        _buildStyledTextField(
          controller: _contractHistoryController,
          label: 'Historique contractuel',
          hintText: 'Clubs précédents, durées, types de contrats...',
          maxLines: 3,
          maxLength: 1000,
        ),
      ],
    );
  }

  // ── Path C: Football – Submission Step ─────────────────────────────────

  Widget _buildSubmissionContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Récapitulatif du dossier',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        _buildReviewCard('Joueur', _playerNameController.text),
        _buildReviewCard('Club actuel', _currentClubController.text),
        _buildReviewCard('Poste', _playerPosition ?? ''),
        if (_transfermarktController.text.isNotEmpty)
          _buildReviewCard('Transfermarkt', _transfermarktController.text),
        if (_highlightVideoController.text.isNotEmpty)
          _buildReviewCard('Vidéo', _highlightVideoController.text),
        _buildReviewCard('Contact', _emailController.text),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.gold.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: AppTheme.gold.withValues(alpha: 0.2)),
          ),
          child: const Column(
            children: [
              Icon(Icons.hourglass_top_rounded,
                  color: AppTheme.gold, size: 32),
              SizedBox(height: 12),
              Text(
                'Votre dossier sera analysé par notre équipe',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppTheme.goldLight,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Vous recevrez une réponse dans les meilleurs délais via la messagerie.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Path D: Charity – Project Step ─────────────────────────────────────

  Widget _buildCharityProjectContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Décrivez votre projet philanthropique',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        _buildStyledTextField(
          controller: _charityProjectController,
          label: 'Description du projet',
          hintText:
              'Objectifs, bénéficiaires, zone géographique, impact attendu...',
          maxLines: 5,
          maxLength: 1000,
        ),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: "Domaine d'impact",
          value: _impactArea,
          items: _impactAreas,
          onChanged: (v) => setState(() => _impactArea = v),
          icon: Icons.volunteer_activism_outlined,
        ),
      ],
    );
  }

  // ── Path D: Charity – Confirmation Step ────────────────────────────────

  Widget _buildConfirmationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Récapitulatif',
          style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 16),
        _buildReviewCard('Projet', _charityProjectController.text),
        _buildReviewCard("Domaine d'impact", _impactArea ?? ''),
        _buildReviewCard('Contact', _emailController.text),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.gold.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(16),
            border:
                Border.all(color: AppTheme.gold.withValues(alpha: 0.2)),
          ),
          child: const Column(
            children: [
              Icon(Icons.volunteer_activism_rounded,
                  color: AppTheme.gold, size: 32),
              SizedBox(height: 12),
              Text(
                'Merci pour votre engagement !',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: AppTheme.goldLight,
                    fontWeight: FontWeight.w600,
                    fontSize: 16),
              ),
              SizedBox(height: 8),
              Text(
                'Notre équipe vous contactera pour discuter des prochaines étapes de votre projet philanthropique.',
                textAlign: TextAlign.center,
                style:
                    TextStyle(color: AppTheme.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Payment Method Item ─────────────────────────────────────────────────────

class _PaymentMethodItem extends StatelessWidget {
  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final String? groupValue;
  final ValueChanged<String?> onChanged;

  const _PaymentMethodItem({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = groupValue == id;
    return InkWell(
      onTap: () => onChanged(id),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? AppTheme.gold : AppTheme.dividerDark,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Text(name,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white)),
            const Spacer(),
            Radio<String>(
              value: id,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: AppTheme.gold,
            ),
          ],
        ),
      ),
    );
  }
}
