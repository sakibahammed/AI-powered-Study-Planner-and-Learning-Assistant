import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/task.dart';

class EditTaskDialog extends StatefulWidget {
  final Task task;
  final Function(Task) onTaskUpdated;
  final Function(String, bool) onTaskStarted;
  final Function(String, bool) onTaskCompleted;
  final Function(String)? onTaskDeleted;

  const EditTaskDialog({
    super.key,
    required this.task,
    required this.onTaskUpdated,
    required this.onTaskStarted,
    required this.onTaskCompleted,
    this.onTaskDeleted,
  });

  @override
  _EditTaskDialogState createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late DateTime _selectedDate;
  late String _selectedCategory;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _descriptionController = TextEditingController(
      text: widget.task.description,
    );
    _selectedDate = widget.task.dueDate;
    _selectedCategory = widget.task.category;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTaskFields(),
                    SizedBox(height: 16),
                    _buildStatusSection(),
                    SizedBox(height: 16),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _getCategoryColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getCategoryIcon(),
              color: _getCategoryColor(),
              size: 20,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Task',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  'Modify your task details',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          if (widget.onTaskDeleted != null)
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: Colors.grey[600]),
              onSelected: (value) async {
                if (value == 'delete') {
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange, size: 24),
                          SizedBox(width: 8),
                          Text('Delete Task'),
                        ],
                      ),
                      content: Text(
                        'Are you sure you want to delete this task? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  );

                  if (shouldDelete == true) {
                    widget.onTaskDeleted!(widget.task.id);
                    Navigator.pop(context);
                  }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red, size: 18),
                      SizedBox(width: 8),
                      Text('Delete Task', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: Colors.grey[600], size: 20),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _titleController,
          label: 'Task Title',
          icon: Icons.title,
        ),
        SizedBox(height: 12),
        _buildTextField(
          controller: _descriptionController,
          label: 'Description',
          icon: Icons.description,
          maxLines: 2,
        ),
        SizedBox(height: 12),
        _buildDateField(),
        SizedBox(height: 12),
        _buildCategoryField(),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: Colors.grey[600], size: 16),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey[600], size: 16),
            SizedBox(width: 8),
            Text(
              'Due Date',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  DateFormat('MMM dd, yyyy').format(_selectedDate),
                  style: TextStyle(fontSize: 14),
                ),
              ),
              TextButton(
                onPressed: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                ),
                child: Text(
                  'Change',
                  style: TextStyle(color: Colors.blue[600], fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.category, color: Colors.grey[600], size: 16),
            SizedBox(width: 8),
            Text(
              'Category',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 4),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 12),
            ),
            items:
                [
                      'Study',
                      'Project',
                      'Health',
                      'Personal',
                      'Errands',
                      'Planning',
                    ]
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
            onChanged: (value) {
              setState(() {
                _selectedCategory = value!;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Task Status',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              _buildStatusChip(
                'Pending',
                Icons.schedule,
                Colors.orange,
                !widget.task.isStarted && !widget.task.isCompleted,
              ),
              SizedBox(width: 8),
              _buildStatusChip(
                'In Progress',
                Icons.play_arrow,
                Colors.blue,
                widget.task.isStarted && !widget.task.isCompleted,
              ),
              SizedBox(width: 8),
              _buildStatusChip(
                'Completed',
                Icons.check_circle,
                Colors.green,
                widget.task.isCompleted,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusChip(
    String label,
    IconData icon,
    Color color,
    bool isActive,
  ) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isActive ? Border.all(color: color, width: 1) : null,
        ),
        child: Column(
          children: [
            Icon(icon, color: isActive ? color : Colors.grey[400], size: 14),
            SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: isActive ? color : Colors.grey[400],
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                text: widget.task.isStarted ? 'Started' : 'Start',
                icon: Icons.play_arrow,
                color: Colors.blue,
                isActive: widget.task.isStarted,
                onPressed: (widget.task.isStarted || widget.task.isCompleted)
                    ? null
                    : () {
                        widget.onTaskStarted(widget.task.id, true);
                        Navigator.pop(context);
                      },
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                text: widget.task.isCompleted ? 'Completed' : 'Complete',
                icon: Icons.check,
                color: Colors.green,
                isActive: widget.task.isCompleted,
                onPressed: (!widget.task.isStarted || widget.task.isCompleted)
                    ? null
                    : () {
                        widget.onTaskCompleted(widget.task.id, true);
                        Navigator.pop(context);
                      },
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  final updatedTask = widget.task.copyWith(
                    title: _titleController.text,
                    description: _descriptionController.text,
                    dueDate: _selectedDate,
                    category: _selectedCategory,
                  );
                  widget.onTaskUpdated(updatedTask);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String text,
    required IconData icon,
    required Color color,
    required bool isActive,
    VoidCallback? onPressed,
  }) {
    final isDisabled = onPressed == null;

    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isActive
              ? color
              : (isDisabled ? color.withOpacity(0.3) : color.withOpacity(0.1)),
          foregroundColor: isActive
              ? Colors.white
              : (isDisabled ? color.withOpacity(0.6) : color.withOpacity(0.8)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16),
            SizedBox(width: 4),
            Text(
              text,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isActive
                    ? Colors.white
                    : (isDisabled
                          ? color.withOpacity(0.6)
                          : color.withOpacity(0.8)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor() {
    switch (_selectedCategory) {
      case 'Study':
        return Colors.blue;
      case 'Project':
        return Colors.orange;
      case 'Health':
        return Colors.green;
      case 'Personal':
        return Colors.purple;
      case 'Errands':
        return Colors.red;
      case 'Planning':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon() {
    switch (_selectedCategory) {
      case 'Study':
        return Icons.school;
      case 'Project':
        return Icons.work;
      case 'Health':
        return Icons.favorite;
      case 'Personal':
        return Icons.person;
      case 'Errands':
        return Icons.shopping_cart;
      case 'Planning':
        return Icons.calendar_month;
      default:
        return Icons.task;
    }
  }
}
