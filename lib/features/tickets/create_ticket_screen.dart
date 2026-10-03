import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/create_ticket_cubit.dart';

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Support Ticket')),
      body: BlocConsumer<CreateTicketCubit, CreateTicketState>(
        listener: (context, state) {
          if (state.status == CreateTicketStatus.done) Navigator.of(context).pop();
          if (state.status == CreateTicketStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage ?? '')));
          }
        },
        builder: (context, state) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Issue title'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 6,
                  decoration: const InputDecoration(labelText: 'Describe the issue in detail', alignLabelWithHint: true),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: state.status == CreateTicketStatus.submitting
                        ? null
                        : () {
                            if (!_formKey.currentState!.validate()) return;
                            context.read<CreateTicketCubit>().submit(_titleCtrl.text.trim(), _descCtrl.text.trim());
                          },
                    child: state.status == CreateTicketStatus.submitting
                        ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                        : const Text('Send Ticket'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
