import 'package:flutter/material.dart';

class SellerAccountPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Placeholder for back button action
          },
        ),
        title: Text('Seller Account'),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle),
            onPressed: () {
              // Placeholder for profile action
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              color: Colors.orange,
              width: double.infinity,
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dear Afoodus',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'You are Under Basic Contract, Click here to upgrade and enjoy our Full Services',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.inbox),
              title: Text('My InBox'),
              trailing: Chip(
                label: Text('2'),
                backgroundColor: Colors.red,
              ),
              onTap: () {
                // Placeholder for My InBox
              },
            ),
            ListTile(
              leading: Icon(Icons.question_answer),
              title: Text('Customer Inquiries'),
              trailing: Chip(
                label: Text('0'),
                backgroundColor: Colors.red,
              ),
              onTap: () {
                // Placeholder for Customer Inquiries
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.store),
              title: Text('My Products'),
              trailing: Chip(
                label: Text('6'),
                backgroundColor: Colors.red,
              ),
              onTap: () {
                // Placeholder for My Products
              },
            ),
            ListTile(
              leading: Icon(Icons.add_circle),
              title: Text('Add New Product'),
              trailing: Icon(
                Icons.add,
                color: Colors.green,
              ),
              onTap: () {
                // Placeholder for Add New Product
              },
            ),
            ListTile(
              leading: Icon(Icons.pending),
              title: Text('Pending to approve'),
              trailing: Chip(
                label: Text('2'),
                backgroundColor: Colors.red,
              ),
              onTap: () {
                // Placeholder for Pending to approve
              },
            ),
            ListTile(
              leading: Icon(Icons.pending_actions),
              title: Text('Pending For Review'),
              trailing: Chip(
                label: Text('0'),
                backgroundColor: Colors.red,
              ),
              onTap: () {
                // Placeholder for Pending For Review
              },
            ),
            ListTile(
              leading: Icon(Icons.cancel),
              title: Text('Rejected Products'),
              trailing: Chip(
                label: Text('1'),
                backgroundColor: Colors.red,
              ),
              onTap: () {
                // Placeholder for Rejected Products
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.contact_support),
              title: Text('Contact Us'),
              onTap: () {
                // Placeholder for Contact Us
              },
            ),
          ],
        ),
      ),
    );
  }
}