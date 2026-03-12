import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
import '../models/activity.dart';
import '../providers/activity_provider.dart';
import '../constants/app_colors.dart';
import '../widgets/custom_button.dart'; // Assuming this exists or use ElevatedButton

class ActivityFormScreen extends StatefulWidget {
  final Activity? activity;

  const ActivityFormScreen({super.key, this.activity});

  @override
  State<ActivityFormScreen> createState() => _ActivityFormScreenState();
}

class _ActivityFormScreenState extends State<ActivityFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late ActivityType _type;
  late TextEditingController _titleController;
  late TextEditingController _locationController;
  late TextEditingController _amountController;
  late TextEditingController _bloodTypeController;
  late DateTime _selectedDate;
  late ActivityStatus _status;

  @override
  void initState() {
    super.initState();
    _type = widget.activity?.type ?? ActivityType.donation;
    _titleController = TextEditingController(text: widget.activity?.title ?? '');
    _locationController = TextEditingController(text: widget.activity?.location ?? '');
    _amountController = TextEditingController(text: widget.activity?.amount ?? '');
    _bloodTypeController = TextEditingController(text: widget.activity?.bloodType ?? '');
    _selectedDate = widget.activity?.date ?? DateTime.now();
    _status = widget.activity?.status ?? ActivityStatus.pending;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _amountController.dispose();
    _bloodTypeController.dispose();
    super.dispose();
  }

  void _saveActivity() {
    if (_formKey.currentState!.validate()) {
      final activity = Activity(
        id: widget.activity?.id ?? const Uuid().v4(),
        type: _type,
        title: _titleController.text,
        location: _locationController.text,
        date: _selectedDate,
        amount: _type == ActivityType.donation ? _amountController.text : null,
        bloodType: _type == ActivityType.sos ? _bloodTypeController.text : null,
        status: _status,
      );

      final provider = Provider.of<ActivityProvider>(context, listen: false);
      if (widget.activity != null) {
        provider.updateActivity(activity);
      } else {
        provider.addActivity(activity);
      }

      Navigator.pop(context);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.activity == null ? 'Thêm Hoạt Động' : 'Sửa Hoạt Động'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Dropdown
              DropdownButtonFormField<ActivityType>(
                value: _type,
                decoration: const InputDecoration(labelText: 'Loại hoạt động'),
                items: const [
                  DropdownMenuItem(value: ActivityType.donation, child: Text('Hiến máu')),
                  DropdownMenuItem(value: ActivityType.sos, child: Text('SOS Cần máu')),
                ],
                onChanged: widget.activity == null
                    ? (value) {
                        setState(() {
                          _type = value!;
                        });
                      }
                    : null, // Disable changing type when editing
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Tiêu đề'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(labelText: 'Địa điểm / Bệnh viện'),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập địa điểm' : null,
              ),
              const SizedBox(height: 16),

              // Date Picker
              InkWell(
                onTap: _pickDate,
                child: InputDecorator(
                  decoration: const InputDecoration(labelText: 'Ngày'),
                  child: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),

              if (_type == ActivityType.donation)
                TextFormField(
                  controller: _amountController,
                  decoration: const InputDecoration(labelText: 'Lượng máu (ví dụ: 350ml)'),
                  validator: (value) => value!.isEmpty ? 'Vui lòng nhập lượng máu' : null,
                ),

              if (_type == ActivityType.sos)
                TextFormField(
                  controller: _bloodTypeController,
                  decoration: const InputDecoration(labelText: 'Nhóm máu cần (ví dụ: A+)'),
                  validator: (value) => value!.isEmpty ? 'Vui lòng nhập nhóm máu' : null,
                ),

              const SizedBox(height: 16),

              DropdownButtonFormField<ActivityStatus>(
                value: _status,
                decoration: const InputDecoration(labelText: 'Trạng thái'),
                items: const [
                  DropdownMenuItem(value: ActivityStatus.pending, child: Text('Đang xử lý')),
                  DropdownMenuItem(value: ActivityStatus.completed, child: Text('Hoàn thành')),
                  DropdownMenuItem(value: ActivityStatus.canceled, child: Text('Đã hủy')),
                ],
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
              ),
              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _saveActivity,
                  child: Text(
                    widget.activity == null ? 'Thêm mới' : 'Lưu thay đổi',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
