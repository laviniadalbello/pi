import 'detalhesdoevento.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'iconedaia.dart';
import 'package:planify/services/gemini_service.dart';
import 'package:planify/services/firestore_tasks_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const Color kDarkPrimaryBg = Color(0xFF1A1A2E);
const Color kDarkSurface = Color(0xFF16213E);
const Color kDarkElementBg = Color(0xFF202A44);
const Color kAccentPurple = Color(0xFF7F5AF0);
const Color kAccentSecondary = Color(0xFF2CB67D);
const Color kDarkTextPrimary = Color(0xFFFFFFFF);
const Color kDarkTextSecondary = Color(0xFFA0AEC0);
const Color kDarkBorder = Color(0xFF2D3748);

class CreateEventPage extends StatefulWidget {
  final Event? eventToEdit;

  const CreateEventPage({super.key, this.eventToEdit});

  @override
  State<CreateEventPage> createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _eventNameController = TextEditingController();
  final _eventDescriptionController = TextEditingController();
  final _eventStartDateController = TextEditingController();
  final _eventStartTimeController = TextEditingController();
  final _eventEndDateController = TextEditingController();
  final _eventEndTimeController = TextEditingController();
  final _eventLocationController = TextEditingController();
  final _eventNotesController = TextEditingController();
  final _participantEmailController = TextEditingController();

  List<Map<String, String>> _participants = [];
  List<String> _attachments = [];
  Color _selectedEventColor = kAccentPurple;

  TimeOfDay? _initialStartTime;
  TimeOfDay? _initialEndTime;

  final List<Color> _availableEventColors = [
    kAccentPurple,
    kAccentSecondary,
    Colors.pinkAccent.shade200,
    Colors.orangeAccent.shade200,
    Colors.teal.shade300,
    Colors.lightBlue.shade300,
    Colors.redAccent.shade200,
    Colors.amber.shade300,
  ];

  bool _isFabMenuActive = false;
  late AnimationController _fabMenuSlideController;
  late Animation<Offset> _fabMenuSlideAnimation;
  late GeminiService _geminiService;
  late FirestoreTasksService _firestoreService;

  @override
  void initState() {
    super.initState();
    _firestoreService = FirestoreTasksService(userId: 'userId');
    _fabMenuSlideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fabMenuSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _fabMenuSlideController, curve: Curves.easeOut),
    );

    _geminiService =
        GeminiService(apiKey: 'AIzaSyBFS5lVuEZzNklLyta4ioepOs2DDw2xPGA');

    if (widget.eventToEdit != null) {
      final event = widget.eventToEdit!;
      _eventNameController.text = event.name;
      _eventDescriptionController.text = event.description ?? '';

      _eventStartDateController.text = DateFormat(
        'dd/MM/yyyy',
      ).format(event.startDate);
      _initialStartTime = event.startTime;

      if (event.endDate != null) {
        _eventEndDateController.text = DateFormat(
          'dd/MM/yyyy',
        ).format(event.endDate!);
      }
      if (event.endTime != null) {
        _initialEndTime = event.endTime;
      }

      _eventLocationController.text = event.location ?? '';
      _selectedEventColor = event.eventColor;
      _participants = List<Map<String, String>>.from(event.participants ?? []);
      _attachments = List<String>.from(event.attachments ?? []);
      _eventNotesController.text = event.notes ?? '';

      // Formatar TimeOfDay após o primeiro frame, pois precisa de BuildContext
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _initialStartTime != null) {
          _eventStartTimeController.text = _initialStartTime!.format(context);
        }
        if (mounted && _initialEndTime != null) {
          _eventEndTimeController.text = _initialEndTime!.format(context);
        }
      });
    }
  }

  @override
  void dispose() {
    _eventNameController.dispose();
    _eventDescriptionController.dispose();
    _eventStartDateController.dispose();
    _eventStartTimeController.dispose();
    _eventEndDateController.dispose();
    _eventEndTimeController.dispose();
    _eventLocationController.dispose();
    _eventNotesController.dispose();
    _participantEmailController.dispose();
    _fabMenuSlideController.dispose();
    _geminiService.close();
    super.dispose();
  }

  void _showAddParticipantDialog() {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: kDarkElementBg,
          title: const Text(
            'Adicionar Participante',
            style: TextStyle(color: kDarkTextPrimary),
          ),
          content: TextField(
            controller: _participantEmailController,
            style: const TextStyle(color: kDarkTextPrimary),
            decoration: InputDecoration(
              hintText: 'E-mail do participante',
              hintStyle: TextStyle(color: kDarkTextSecondary.withOpacity(0.7)),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: kDarkTextSecondary),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: kAccentPurple),
              ),
            ),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'Cancelar',
                style: TextStyle(color: kDarkTextSecondary),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _participantEmailController.clear();
              },
            ),
            TextButton(
              child: const Text(
                'Adicionar',
                style: TextStyle(color: kAccentPurple),
              ),
              onPressed: () {
                if (_participantEmailController.text.isNotEmpty &&
                    _participantEmailController.text.contains('@')) {
                  if (mounted) {
                    setState(() {
                      String email = _participantEmailController.text;
                      String name = email.split('@')[0];
                      if (name.isNotEmpty) {
                        name = name[0].toUpperCase() + name.substring(1);
                      }
                      _participants.add({"name": name, "email": email});
                    });
                  }
                  Navigator.of(dialogContext).pop();
                  _participantEmailController.clear();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Por favor, insira um e-mail válido.',
                        style: TextStyle(color: kDarkTextPrimary),
                      ),
                      backgroundColor: kDarkElementBg,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(
    TextEditingController controller, {
    DateTime? initialDate,
  }) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: kAccentPurple,
              onPrimary: kDarkTextPrimary,
              surface: kDarkSurface,
              onSurface: kDarkTextPrimary,
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
            dialogTheme: const DialogThemeData(backgroundColor: kDarkElementBg),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      if (mounted) {
        setState(() {
          controller.text = formattedDate;
        });
      }
    }
  }

  Future<void> _selectTime(
    TextEditingController controller, {
    TimeOfDay? initialTime,
  }) async {
    TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: kAccentPurple,
              onPrimary: kDarkTextPrimary,
              surface: kDarkSurface,
              onSurface: kDarkTextPrimary,
            ),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
            timePickerTheme: const TimePickerThemeData(
              backgroundColor: kDarkElementBg,
              hourMinuteTextColor: kDarkTextPrimary,
              hourMinuteColor: kDarkSurface,
              dayPeriodTextColor: kDarkTextPrimary,
              dayPeriodColor: kDarkSurface,
              dialHandColor: kAccentPurple,
              dialBackgroundColor: kDarkSurface,
              entryModeIconColor: kAccentPurple,
              helpTextStyle: TextStyle(color: kDarkTextSecondary),
            ),
            dialogTheme: const DialogThemeData(backgroundColor: kDarkElementBg),
          ),
          child: child!,
        );
      },
    );
    if (pickedTime != null) {
      if (mounted) {
        setState(() {
          controller.text = pickedTime.format(context);
          // Atualizar _initialStartTime ou _initialEndTime se estiver editando e o usuário mudar a hora
          if (controller == _eventStartTimeController) {
            _initialStartTime = pickedTime;
          }
          if (controller == _eventEndTimeController) {
            _initialEndTime = pickedTime;
          }
        });
      }
    }
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      DateTime? startDate;
      TimeOfDay? tempStartTime =
          _initialStartTime; // Use o TimeOfDay armazenado se estiver editando
      DateTime? endDate;
      TimeOfDay? tempEndTime =
          _initialEndTime; // Use o TimeOfDay armazenado se estiver editando

      try {
        if (_eventStartDateController.text.isNotEmpty) {
          startDate = DateFormat(
            'dd/MM/yyyy',
          ).parse(_eventStartDateController.text);
        }
        // Se não estiver editando ou se o texto do controller mudou
        if (widget.eventToEdit == null ||
            _eventStartTimeController.text !=
                (_initialStartTime?.format(context) ?? '')) {
          if (_eventStartTimeController.text.isNotEmpty) {
            final timeParts = _eventStartTimeController.text.split(
              RegExp(r'[:\s]'),
            );
            tempStartTime = TimeOfDay(
              hour: int.parse(timeParts[0]),
              minute: int.parse(timeParts[1]),
            );
          }
        }

        if (_eventEndDateController.text.isNotEmpty) {
          endDate = DateFormat(
            'dd/MM/yyyy',
          ).parse(_eventEndDateController.text);
        }
        if (widget.eventToEdit == null ||
            _eventEndTimeController.text !=
                (_initialEndTime?.format(context) ?? '')) {
          if (_eventEndTimeController.text.isNotEmpty) {
            final timeParts = _eventEndTimeController.text.split(
              RegExp(r'[:\s]'),
            );
            tempEndTime = TimeOfDay(
              hour: int.parse(timeParts[0]),
              minute: int.parse(timeParts[1]),
            );
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erro ao processar datas/horas. Verifique os formatos. $e',
              style: const TextStyle(color: kDarkTextPrimary),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      if (startDate == null || tempStartTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Data e Hora de início são obrigatórias.',
              style: TextStyle(color: kDarkTextPrimary),
            ),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }
      if ((endDate != null && tempEndTime == null) ||
          (endDate == null && tempEndTime != null)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Se a Data de Término for fornecida, a Hora de Término também deve ser, e vice-versa.',
              style: TextStyle(color: kDarkTextPrimary),
            ),
            backgroundColor: Colors.orangeAccent,
          ),
        );
        return;
      }

      Event eventData = Event(
        id: widget.eventToEdit?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        name: _eventNameController.text,
        description: _eventDescriptionController.text.isNotEmpty
            ? _eventDescriptionController.text
            : null,
        startDate: startDate,
        startTime: tempStartTime,
        endDate: endDate,
        endTime: tempEndTime,
        location: _eventLocationController.text.isNotEmpty
            ? _eventLocationController.text
            : null,
        eventColor: _selectedEventColor,
        participants: _participants,
        attachments: _attachments,
        notes: _eventNotesController.text.isNotEmpty
            ? _eventNotesController.text
            : null,
        status: widget.eventToEdit?.status ?? EventStatus.upcoming,
      );

      String action = widget.eventToEdit != null ? "atualizado" : "criado";
      print("Evento $action: ${eventData.name}");
      await _saveEventToFirestore(eventData);
      Navigator.pop(context, eventData); // Retorna o evento

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Evento $action com sucesso!',
            style: const TextStyle(color: kDarkTextPrimary),
          ),
          backgroundColor: kAccentSecondary,
        ),
      );
    }
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    IconData? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    bool isOptional = false,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: kDarkTextPrimary),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: kDarkTextSecondary),
        filled: true,
        fillColor: kDarkElementBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: kAccentPurple, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 14.0,
        ),
        suffixIcon: suffixIcon != null
            ? Icon(suffixIcon, color: kDarkTextSecondary)
            : null,
      ),
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      keyboardType: keyboardType,
      validator: validator ??
          (value) {
            if (!isOptional && (value == null || value.isEmpty)) {
              return 'Por favor, preencha este campo.';
            }
            return null;
          },
    );
  }

  void _toggleFabMenuVisibility() {
    if (mounted) {
      setState(() {
        _isFabMenuActive = !_isFabMenuActive;
        if (_isFabMenuActive) {
          _fabMenuSlideController.forward();
        } else {
          _fabMenuSlideController.reverse();
        }
      });
    }
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      backgroundColor: kAccentPurple,
      elevation: 6,
      shape: const CircleBorder(),
      onPressed: _toggleFabMenuVisibility,
      child: Icon(
        _isFabMenuActive ? Icons.close : Icons.add,
        color: kDarkTextPrimary,
        size: 28,
      ),
    );
  }

  Widget _buildDimOverlay() {
    return GestureDetector(
      onTap: _toggleFabMenuVisibility,
      child: Container(color: Colors.black.withOpacity(0.6)),
    );
  }

  Widget _buildFabSlidingMenu() {
    return Positioned(
      bottom: 80,
      left: 30,
      right: 30,
      child: SlideTransition(
        position: _fabMenuSlideAnimation,
        child: Material(
          color: Colors.transparent,
          elevation: 8,
          borderRadius: BorderRadius.circular(24),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
            decoration: BoxDecoration(
              color: kDarkElementBg,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _menuItem(
                  Icons.attach_file,
                  'Anexar Arquivo',
                  onTapAction: _pickFiles,
                ),
                const SizedBox(height: 12),
                _menuItem(
                  Icons.notifications_none_outlined,
                  'Definir Lembrete',
                  onTapAction: () {
                    print("Definir Lembrete Tocado");
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "Lembrete para evento (simulação)",
                          style: TextStyle(color: kDarkTextPrimary),
                        ),
                        backgroundColor: kDarkSurface,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                FloatingActionButton(
                  mini: true,
                  backgroundColor: kAccentPurple,
                  elevation: 0,
                  shape: const CircleBorder(),
                  onPressed: _toggleFabMenuVisibility,
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: kDarkTextPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _menuItem(IconData icon, String label, {VoidCallback? onTapAction}) {
    return GestureDetector(
      onTap: () {
        if (onTapAction != null) {
          onTapAction();
        }
        _toggleFabMenuVisibility();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: kDarkSurface.withOpacity(0.7),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kDarkBorder.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Icon(icon, color: kDarkTextSecondary, size: 20),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                color: kDarkTextSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickFiles() async {
    // Simulação de anexar arquivos
    if (mounted) {
      setState(() {
        _attachments.add("evento_doc_${_attachments.length + 1}.pdf");
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Arquivo "${_attachments.last}" anexado (simulação).',
            style: const TextStyle(color: kDarkTextPrimary),
          ),
          backgroundColor: kAccentSecondary,
        ),
      );
    }
    print("Função _pickFiles para evento chamada.");
  }

  Widget _buildParticipantSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ..._participants.map((participant) {
            return _participantAvatar(
              participant['imageUrl'],
              participant['name'] ?? 'N/A',
            );
          }),
          _addParticipantButton(),
        ],
      ),
    );
  }

  Widget _participantAvatar(String? imageUrl, String name) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: kDarkElementBg,
            backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
            child: imageUrl == null
                ? Text(
                    name.isNotEmpty ? name[0].toUpperCase() : '?',
                    style: const TextStyle(
                      color: kDarkTextPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(color: kDarkTextSecondary, fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _addParticipantButton() {
    return GestureDetector(
      onTap: _showAddParticipantDialog,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: Column(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: kDarkElementBg,
                shape: BoxShape.circle,
                border: Border.all(
                  color: kDarkTextSecondary.withOpacity(0.5),
                  width: 1.5,
                ),
              ),
              child: const Icon(Icons.add, color: kDarkTextSecondary, size: 28),
            ),
            const SizedBox(height: 4),
            const Text(
              "Adic.",
              style: TextStyle(color: kDarkTextSecondary, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSelector() {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _availableEventColors.length,
        itemBuilder: (context, index) {
          Color color = _availableEventColors[index];
          bool isSelected = color == _selectedEventColor;
          return GestureDetector(
            onTap: () {
              if (mounted) {
                setState(() {
                  _selectedEventColor = color;
                });
              }
            },
            child: Container(
              margin: const EdgeInsets.only(right: 10),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: kDarkTextPrimary, width: 2.5)
                    : Border.all(color: color.withOpacity(0.5), width: 1),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: color.withOpacity(0.5),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ]
                    : [],
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check,
                      color: kDarkTextPrimary,
                      size: 20,
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }

  Future<void> _saveEventToFirestore(Event event) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final eventData = {
      'title': event.name,
      'description': event.description ?? '',
      'startTime': Timestamp.fromDate(event.startDate),
      'endTime':
          event.endDate != null ? Timestamp.fromDate(event.endDate!) : null,
      'location': event.location ?? '',
      'status': event.status.toString(),
      'userId': user.uid,
      // Adicione outros campos se necessário
    };

    await FirebaseFirestore.instance
        .collection('events')
        .doc(event.id)
        .set(eventData, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark().copyWith(
        primaryColor: kDarkPrimaryBg,
        scaffoldBackgroundColor: kDarkPrimaryBg,
        colorScheme: const ColorScheme.dark(
          primary: kAccentPurple,
          secondary: kAccentSecondary,
          surface: kDarkSurface,
          error: Colors.redAccent,
          onPrimary: kDarkTextPrimary,
          onSecondary: kDarkTextPrimary,
          onSurface: kDarkTextPrimary,
          onError: kDarkTextPrimary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: kDarkSurface,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: kDarkTextPrimary),
          titleTextStyle: TextStyle(
            color: kDarkTextPrimary,
            fontWeight: FontWeight.bold,
            fontSize: widget.eventToEdit == null ? 20 : 18,
          ), // Ajuste de tamanho para título mais longo
        ),
        inputDecorationTheme: InputDecorationTheme(
          hintStyle: TextStyle(color: kDarkTextSecondary.withOpacity(0.7)),
          labelStyle: const TextStyle(color: kDarkTextSecondary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: kAccentPurple, width: 1.5),
          ),
          filled: true,
          fillColor: kDarkElementBg,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 14.0,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: kAccentPurple),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kAccentPurple,
            foregroundColor: kDarkTextPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            widget.eventToEdit == null
                ? 'Criar Novo Evento'
                : 'Editar Evento: ${widget.eventToEdit!.name}',
          ), // MODIFICAÇÃO: Título dinâmico
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: kDarkTextPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: IconButton(
                icon: const Icon(
                  Icons.check,
                  color: kAccentSecondary,
                  size: 28,
                ),
                onPressed: _submitForm,
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20.0),
                children: <Widget>[
                  const Text(
                    'DETALHES DO EVENTO',
                    style: TextStyle(
                      color: kDarkTextSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    _eventNameController,
                    'Nome do Evento',
                    suffixIcon: Icons.event_note,
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    _eventDescriptionController,
                    'Descrição',
                    maxLines: 3,
                    suffixIcon: Icons.description_outlined,
                    isOptional: true,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          _eventStartDateController,
                          'Data de Início',
                          readOnly: true,
                          onTap: () => _selectDate(
                            _eventStartDateController,
                            initialDate: widget.eventToEdit?.startDate,
                          ),
                          suffixIcon: Icons.calendar_today,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          _eventStartTimeController,
                          'Hora de Início',
                          readOnly: true,
                          onTap: () => _selectTime(
                            _eventStartTimeController,
                            initialTime: _initialStartTime,
                          ),
                          suffixIcon: Icons.access_time,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTextField(
                          _eventEndDateController,
                          'Data de Término (Opcional)',
                          readOnly: true,
                          onTap: () => _selectDate(
                            _eventEndDateController,
                            initialDate: widget.eventToEdit?.endDate ??
                                (_eventStartDateController.text.isNotEmpty
                                    ? (() {
                                        try {
                                          return DateFormat(
                                            'dd/MM/yyyy',
                                          ).parse(
                                            _eventStartDateController.text,
                                          );
                                        } catch (e) {
                                          return DateTime.now();
                                        }
                                      })()
                                    : DateTime.now()),
                          ),
                          suffixIcon: Icons.calendar_today,
                          isOptional: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildTextField(
                          _eventEndTimeController,
                          'Hora de Término (Opcional)',
                          readOnly: true,
                          onTap: () => _selectTime(
                            _eventEndTimeController,
                            initialTime: _initialEndTime,
                          ),
                          suffixIcon: Icons.access_time,
                          isOptional: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildTextField(
                    _eventLocationController,
                    'Local (Endereço ou Link)',
                    suffixIcon: Icons.location_on_outlined,
                    isOptional: true,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'COR DO EVENTO',
                    style: TextStyle(
                      color: kDarkTextSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildColorSelector(),
                  const SizedBox(height: 24),
                  const Text(
                    'PARTICIPANTES / CONVIDADOS',
                    style: TextStyle(
                      color: kDarkTextSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildParticipantSection(),
                  const SizedBox(height: 24),
                  _buildTextField(
                    _eventNotesController,
                    'Notas Adicionais',
                    maxLines: 4,
                    suffixIcon: Icons.note_add_outlined,
                    isOptional: true,
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            if (_isFabMenuActive) _buildDimOverlay(),
            if (_isFabMenuActive) _buildFabSlidingMenu(),
            Positioned(
              bottom: 42,
              right: -60,
              child: CloseableAiCard(
                geminiService: _geminiService,
                firestoreService: _firestoreService,
                scaleFactor:
                    MediaQuery.of(context).size.width < 360 ? 0.35 : 0.4,
                enableScroll: true,
              ),
            ),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
