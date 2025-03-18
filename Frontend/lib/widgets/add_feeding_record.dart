import 'package:flutter/material.dart';

class AddFeedingRecordPopup extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  final Map<String, dynamic> animal;

  const AddFeedingRecordPopup({super.key, required this.onSubmit, required this.animal});

  @override
  State<AddFeedingRecordPopup> createState() => _AddFeedingRecordPopupState();
}

class _AddFeedingRecordPopupState extends State<AddFeedingRecordPopup> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> formData = {
    "cattle_name": "",
    "health_status": "healthy",
    "status": "Active",
    "food_type_morning": "",
    "feeding_amount_KG_morning": 0.0,
    "score_morning": 0,
    "food_type_noon": "",
    "feeding_amount_KG_noon": 0.0,
    "score_noon": 0,
    "food_type_evening": "",
    "feeding_amount_KG_evening": 0.0,
    "score_evening": 0,
    "feed_platform": "",
    "travel_distance_per_day_KM": 0.0,
    "farmers_id": "",
    "farmer_name": "",
  };

  @override
  void initState() {
    super.initState();
    formData["cattle_name"] = widget.animal['name'] ?? "";
    formData["status"] = widget.animal['status'] ?? "Active";
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Add Feeding Record",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),
                ..._buildFormFields(),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: _handleSubmit,
                      child: const Text("Submit"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFormFields() {
    return [
      _buildReadOnlyField("Cattle Name", formData["cattle_name"]),
      _buildDropdownField(
        label: "Health Status",
        value: formData["health_status"],
        items: ["healthy", "sick"],
        onChanged: (value) {
          setState(() {
            formData["health_status"] = value!;
          });
        },
      ),
      _buildDropdownField(
        label: "Status",
        value: formData["status"],
        items: ["Active", "Inactive"],
        onChanged: (value) {
          setState(() {
            formData["status"] = value!;
          });
        },
      ),
      ..._buildFoodFields(),
      _buildNumericField(
        label: "Travel Distance (KM)",
        key: "travel_distance_per_day_KM",
      ),
      _buildTextField(
        label: "Farmer's ID",
        key: "farmers_id",
      ),
      _buildTextField(
        label: "Farmer's Name",
        key: "farmer_name",
      ),
    ];
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(labelText: label),
        initialValue: value,
        readOnly: true,
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<String>(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white), // Label text color
          enabledBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white), // Border color
          ),
          focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white), // Border color when focused
          ),
        ),
        value: value,
        items: items
            .map((item) => DropdownMenuItem<String>(
          value: item,
          child: Text(
            item,
            style: const TextStyle(color: Colors.white), // Options text color
          ),
        ))
            .toList(),
        onChanged: onChanged,
        dropdownColor: Colors.black, // Dropdown background color
        style: const TextStyle(color: Colors.white), // Selected text color
      ),
    );
  }


  List<Widget> _buildFoodFields() {
    return [
      _buildTextField(label: "Food Type (Morning)", key: "food_type_morning"),
      _buildNumericField(label: "Feeding Amount (KG) Morning", key: "feeding_amount_KG_morning"),
      _buildNumericField(label: "Score (Morning)", key: "score_morning"),
      _buildTextField(label: "Food Type (Noon)", key: "food_type_noon"),
      _buildNumericField(label: "Feeding Amount (KG) Noon", key: "feeding_amount_KG_noon"),
      _buildNumericField(label: "Score (Noon)", key: "score_noon"),
      _buildTextField(label: "Food Type (Evening)", key: "food_type_evening"),
      _buildNumericField(label: "Feeding Amount (KG) Evening", key: "feeding_amount_KG_evening"),
      _buildNumericField(label: "Score (Evening)", key: "score_evening"),
    ];
  }

  Widget _buildTextField({required String label, required String key}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(labelText: label),
        onSaved: (value) {
          if (value != null && value.isNotEmpty) {
            formData[key] = value;
          }
        },
      ),
    );
  }

  Widget _buildNumericField({required String label, required String key}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        decoration: InputDecoration(labelText: label),
        keyboardType: TextInputType.number,
        onSaved: (value) {
          if (value != null && value.isNotEmpty) {
            formData[key] = double.tryParse(value) ?? 0.0;
          }
        },
      ),
    );
  }

  void _handleSubmit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSubmit(formData);
      Navigator.of(context).pop();
    }
  }
}
