📄 docs/BILLING-INTEGRATION.md
markdown
# Billing Integration Guide

## Integrating Billing Systems with MikroTik ISP

---

## 1. Introduction

This guide covers the integration of billing systems with MikroTik routers for ISP management. It includes:
- Billing system architecture
- API integration
- Automated provisioning
- Payment processing
- Customer management

---

## 2. Billing System Architecture

### 2.1 Components
┌─────────────────────────────────────────────────────────────┐
│ Billing System │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ Web Interface │ API Gateway ││
│ │ Customer Portal │ Payment Gateway ││
│ │ Admin Dashboard │ Invoice Management ││
│ └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
│
▼
┌─────────────────────────────────────────────────────────────┐
│ RADIUS Server │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ Authentication │ Accounting ││
│ │ User Management │ Session Management ││
│ └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
│
▼
┌─────────────────────────────────────────────────────────────┐
│ MikroTik Router │
│ ┌─────────────────────────────────────────────────────────┐│
│ │ PPPoE Server │ Hotspot Server ││
│ │ Firewall │ QoS ││
│ └─────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘

text

### 2.2 Data Flow
Customer signs up through web portal

Billing system creates user in RADIUS

RADIUS authenticates user on MikroTik

MikroTik sends accounting to RADIUS

RADIUS sends accounting to billing system

Billing system generates invoices

Customer pays through payment gateway

Billing system updates user status

RADIUS applies changes to user

MikroTik enforces policy

text

---

## 3. API Integration

### 3.1 RADIUS API Endpoints

```python
# Python Flask API for RADIUS Integration
from flask import Flask, request, jsonify
import mysql.connector
import hashlib

app = Flask(__name__)

# Database connection
def get_db():
    return mysql.connector.connect(
        host="localhost",
        user="radius",
        password="radius-password",
        database="radius"
    )

# Create user
@app.route('/api/user/create', methods=['POST'])
def create_user():
    data = request.json
    username = data.get('username')
    password = data.get('password')
    package = data.get('package')
    
    db = get_db()
    cursor = db.cursor()
    
    # Add user to RADIUS
    cursor.execute(
        "INSERT INTO radcheck (username, attribute, op, value) "
        "VALUES (%s, 'Cleartext-Password', ':=', %s)",
        (username, password)
    )
    
    cursor.execute(
        "INSERT INTO radusergroup (username, groupname, priority) "
        "VALUES (%s, %s, 1)",
        (username, package)
    )
    
    db.commit()
    cursor.close()
    db.close()
    
    return jsonify({"status": "success", "message": "User created"})

# Update user
@app.route('/api/user/update', methods=['PUT'])
def update_user():
    data = request.json
    username = data.get('username')
    package = data.get('package')
    status = data.get('status')
    
    db = get_db()
    cursor = db.cursor()
    
    if package:
        cursor.execute(
            "UPDATE radusergroup SET groupname = %s WHERE username = %s",
            (package, username)
        )
    
    if status == 'disabled':
        cursor.execute(
            "DELETE FROM radcheck WHERE username = %s "
            "AND attribute = 'Cleartext-Password'",
            (username,)
        )
    elif status == 'enabled':
        cursor.execute(
            "INSERT INTO radcheck (username, attribute, op, value) "
            "SELECT %s, 'Cleartext-Password', ':=', password "
            "FROM user_backup WHERE username = %s",
            (username, username)
        )
    
    db.commit()
    cursor.close()
    db.close()
    
    return jsonify({"status": "success", "message": "User updated"})

# Delete user
@app.route('/api/user/delete', methods=['DELETE'])
def delete_user():
    data = request.json
    username = data.get('username')
    
    db = get_db()
    cursor = db.cursor()
    
    cursor.execute("DELETE FROM radcheck WHERE username = %s", (username,))
    cursor.execute("DELETE FROM radusergroup WHERE username = %s", (username,))
    cursor.execute("DELETE FROM radacct WHERE username = %s", (username,))
    
    db.commit()
    cursor.close()
    db.close()
    
    return jsonify({"status": "success", "message": "User deleted"})

# Get user info
@app.route('/api/user/info/<username>', methods=['GET'])
def get_user_info(username):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    
    # Get user details
    cursor.execute("""
        SELECT 
            u.username,
            u.value as password,
            g.groupname as package,
            a.acctinputoctets as download,
            a.acctoutputoctets as upload,
            a.acctsessiontime as session_time
        FROM radcheck u
        LEFT JOIN radusergroup g ON u.username = g.username
        LEFT JOIN radacct a ON u.username = a.username
        WHERE u.username = %s
        AND a.acctstoptime IS NULL
    """, (username,))
    
    user = cursor.fetchone()
    cursor.close()
    db.close()
    
    return jsonify(user)

# Get usage statistics
@app.route('/api/user/stats/<username>', methods=['GET'])
def get_user_stats(username):
    db = get_db()
    cursor = db.cursor(dictionary=True)
    
    cursor.execute("""
        SELECT 
            SUM(acctinputoctets) as total_download,
            SUM(acctoutputoctets) as total_upload,
            SUM(acctsessiontime) as total_time,
            COUNT(*) as sessions,
            MAX(acctstarttime) as last_login
        FROM radacct
        WHERE username = %s
        AND acctstarttime > DATE_SUB(NOW(), INTERVAL 30 DAY)
    """, (username,))
    
    stats = cursor.fetchone()
    cursor.close()
    db.close()
    
    return jsonify(stats)

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
3.2 Billing System Integration
python
# Billing System API Integration
import requests
import json

class BillingIntegration:
    def __init__(self, base_url, api_key):
        self.base_url = base_url
        self.headers = {
            'Authorization': f'Bearer {api_key}',
            'Content-Type': 'application/json'
        }
    
    def create_user(self, username, password, package):
        data = {
            'username': username,
            'password': password,
            'package': package
        }
        response = requests.post(
            f'{self.base_url}/api/user/create',
            headers=self.headers,
            json=data
        )
        return response.json()
    
    def update_user(self, username, package=None, status=None):
        data = {
            'username': username,
            'package': package,
            'status': status
        }
        response = requests.put(
            f'{self.base_url}/api/user/update',
            headers=self.headers,
            json=data
        )
        return response.json()
    
    def delete_user(self, username):
        data = {'username': username}
        response = requests.delete(
            f'{self.base_url}/api/user/delete',
            headers=self.headers,
            json=data
        )
        return response.json()
    
    def get_user_info(self, username):
        response = requests.get(
            f'{self.base_url}/api/user/info/{username}',
            headers=self.headers
        )
        return response.json()
    
    def get_user_stats(self, username):
        response = requests.get(
            f'{self.base_url}/api/user/stats/{username}',
            headers=self.headers
        )
        return response.json()

# Usage example
billing = BillingIntegration('http://localhost:5000', 'api-key-123')
user = billing.create_user('customer1', 'pass123', '10Mbps')
stats = billing.get_user_stats('customer1')
4. Payment Gateway Integration
4.1 bKash Integration
python
import requests
import json

class bKashIntegration:
    def __init__(self, app_key, app_secret, username, password):
        self.app_key = app_key
        self.app_secret = app_secret
        self.username = username
        self.password = password
        self.base_url = "https://api.bkash.com"
        
    def get_token(self):
        url = f"{self.base_url}/tokenized/checkout/token/grant"
        headers = {
            'Content-Type': 'application/json',
            'X-APP-KEY': self.app_key,
            'X-APP-SECRET': self.app_secret
        }
        data = {
            'app_key': self.app_key,
            'app_secret': self.app_secret
        }
        response = requests.post(url, headers=headers, json=data)
        return response.json()['id_token']
    
    def create_payment(self, amount, invoice_number):
        token = self.get_token()
        url = f"{self.base_url}/tokenized/checkout/create"
        headers = {
            'Content-Type': 'application/json',
            'Authorization': token,
            'X-APP-KEY': self.app_key
        }
        data = {
            'mode': '0011',
            'payerReference': invoice_number,
            'callbackURL': 'https://yourdomain.com/payment/callback',
            'amount': amount,
            'currency': 'BDT',
            'intent': 'sale',
            'merchantInvoiceNumber': invoice_number
        }
        response = requests.post(url, headers=headers, json=data)
        return response.json()
    
    def execute_payment(self, payment_id):
        token = self.get_token()
        url = f"{self.base_url}/tokenized/checkout/execute"
        headers = {
            'Content-Type': 'application/json',
            'Authorization': token,
            'X-APP-KEY': self.app_key
        }
        data = {
            'paymentID': payment_id
        }
        response = requests.post(url, headers=headers, json=data)
        return response.json()

# Usage
bkash = bKashIntegration('app-key', 'app-secret', 'user', 'pass')
payment = bkash.create_payment(500, 'INV-2024-001')
print(payment)
4.2 Nagad Integration
python
class NagadIntegration:
    def __init__(self, merchant_id, public_key, private_key):
        self.merchant_id = merchant_id
        self.public_key = public_key
        self.private_key = private_key
        self.base_url = "https://api.nagad.com"
    
    def create_payment(self, amount, order_id):
        # Nagad payment creation logic
        pass
    
    def verify_payment(self, payment_id):
        # Nagad payment verification logic
        pass
4.3 Rocket Integration
python
class RocketIntegration:
    def __init__(self, merchant_id, api_key):
        self.merchant_id = merchant_id
        self.api_key = api_key
        self.base_url = "https://api.rocket.com"
    
    def create_payment(self, amount, phone_number):
        # Rocket payment creation logic
        pass
    
    def check_status(self, transaction_id):
        # Rocket transaction status check
        pass
5. Automated Provisioning
5.1 User Provisioning Script
bash
#!/bin/bash
# /usr/local/bin/provision-user.sh

USERNAME=$1
PASSWORD=$2
PACKAGE=$3
EMAIL=$4
PHONE=$5

# Create user in RADIUS
mysql -u radius -pradius-password radius <<EOF
INSERT INTO radcheck (username, attribute, op, value) 
VALUES ('$USERNAME', 'Cleartext-Password', ':=', '$PASSWORD');

INSERT INTO radusergroup (username, groupname, priority) 
VALUES ('$USERNAME', '$PACKAGE', 1);

INSERT INTO user_info (username, email, phone, created_date) 
VALUES ('$USERNAME', '$EMAIL', '$PHONE', NOW());
EOF

# Create hotspot user (if enabled)
mysql -u radius -pradius-password radius <<EOF
INSERT INTO hotspot_users (username, password, profile, status) 
VALUES ('$USERNAME', '$PASSWORD', '$PACKAGE', 'active');
EOF

# Send welcome email
echo "Welcome $USERNAME" | mail -s "ISP Account Created" $EMAIL

echo "User $USERNAME provisioned successfully"
5.2 Auto Suspension Script
bash
#!/bin/bash
# /usr/local/bin/suspend-expired.sh

# Find expired users
EXPIRED_USERS=$(mysql -u radius -pradius-password radius -s -N -e "
SELECT username FROM billing_invoices 
WHERE status = 'overdue' 
AND due_date < DATE_SUB(NOW(), INTERVAL 7 DAY)
AND username NOT IN (SELECT username FROM suspended_users);
")

# Suspend expired users
for USER in $EXPIRED_USERS; do
    echo "Suspending $USER"
    
    # Disable user in RADIUS
    mysql -u radius -pradius-password radius <<EOF
DELETE FROM radcheck WHERE username = '$USER' AND attribute = 'Cleartext-Password';
INSERT INTO suspended_users (username, suspended_date) VALUES ('$USER', NOW());
EOF
    
    # Kill active session
    /usr/local/bin/kill-session.sh $USER
    
    # Send notification
    echo "Your account has been suspended due to non-payment" | mail -s "Account Suspended" $USER
    
    echo "User $USER suspended"
done
5.3 Auto Reactivation Script
bash
#!/bin/bash
# /usr/local/bin/reactivate-user.sh

USERNAME=$1

# Check if user exists in backup
if mysql -u radius -pradius-password radius -s -N -e "
SELECT COUNT(*) FROM user_backup WHERE username = '$USERNAME';" | grep -q 1; then
    
    # Reactivate user
    mysql -u radius -pradius-password radius <<EOF
INSERT INTO radcheck (username, attribute, op, value)
SELECT '$USERNAME', 'Cleartext-Password', ':=', password
FROM user_backup WHERE username = '$USERNAME';

DELETE FROM suspended_users WHERE username = '$USERNAME';
EOF
    
    echo "User $USERNAME reactivated"
else
    echo "User $USERNAME not found in backup"
fi
6. Customer Portal
6.1 Portal Interface
html
<!-- customer-portal.html -->
<!DOCTYPE html>
<html>
<head>
    <title>ISP Customer Portal</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
    <div class="container">
        <h1>Customer Portal</h1>
        
        <div class="login-form">
            <h2>Login</h2>
            <input type="text" id="username" placeholder="Username">
            <input type="password" id="password" placeholder="Password">
            <button onclick="login()">Login</button>
        </div>
        
        <div id="dashboard" style="display:none">
            <h2>Dashboard</h2>
            <div class="stats">
                <div class="stat">
                    <h3>Download</h3>
                    <p id="download">0 GB</p>
                </div>
                <div class="stat">
                    <h3>Upload</h3>
                    <p id="upload">0 GB</p>
                </div>
                <div class="stat">
                    <h3>Package</h3>
                    <p id="package">-</p>
                </div>
                <div class="stat">
                    <h3>Status</h3>
                    <p id="status">-</p>
                </div>
            </div>
            
            <div class="actions">
                <button onclick="viewInvoices()">View Invoices</button>
                <button onclick="makePayment()">Make Payment</button>
                <button onclick="changePackage()">Change Package</button>
                <button onclick="viewHistory()">View History</button>
            </div>
            
            <div id="invoices" style="display:none">
                <h3>Invoices</h3>
                <table id="invoiceTable">
                    <thead>
                        <tr>
                            <th>Invoice #</th>
                            <th>Amount</th>
                            <th>Due Date</th>
                            <th>Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="invoiceBody">
                    </tbody>
                </table>
            </div>
        </div>
    </div>
    
    <script src="portal.js"></script>
</body>
</html>
6.2 Portal JavaScript
javascript
// portal.js
const API_URL = 'https://api.yourisp.com';

function login() {
    const username = document.getElementById('username').value;
    const password = document.getElementById('password').value;
    
    fetch(`${API_URL}/auth/login`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({
            username: username,
            password: password
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            localStorage.setItem('token', data.token);
            localStorage.setItem('username', username);
            showDashboard();
        } else {
            alert('Login failed: ' + data.message);
        }
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Login failed');
    });
}

function showDashboard() {
    document.querySelector('.login-form').style.display = 'none';
    document.getElementById('dashboard').style.display = 'block';
    loadDashboard();
}

function loadDashboard() {
    const username = localStorage.getItem('username');
    const token = localStorage.getItem('token');
    
    fetch(`${API_URL}/api/user/info/${username}`, {
        headers: {
            'Authorization': `Bearer ${token}`
        }
    })
    .then(response => response.json())
    .then(data => {
        document.getElementById('download').textContent = 
            formatBytes(data.download || 0);
        document.getElementById('upload').textContent = 
            formatBytes(data.upload || 0);
        document.getElementById('package').textContent = 
            data.package || 'N/A';
        document.getElementById('status').textContent = 
            data.status || 'Active';
    })
    .catch(error => {
        console.error('Error:', error);
    });
}

function viewInvoices() {
    const username = localStorage.getItem('username');
    const token = localStorage.getItem('token');
    
    fetch(`${API_URL}/api/invoices/${username}`, {
        headers: {
            'Authorization': `Bearer ${token}`
        }
    })
    .then(response => response.json())
    .then(data => {
        const tbody = document.getElementById('invoiceBody');
        tbody.innerHTML = '';
        
        data.invoices.forEach(invoice => {
            const row = tbody.insertRow();
            row.innerHTML = `
                <td>${invoice.number}</td>
                <td>${invoice.amount} BDT</td>
                <td>${invoice.due_date}</td>
                <td>${invoice.status}</td>
                <td>
                    <button onclick="payInvoice('${invoice.id}')">
                        Pay
                    </button>
                </td>
            `;
        });
        
        document.getElementById('invoices').style.display = 'block';
    })
    .catch(error => {
        console.error('Error:', error);
        alert('Failed to load invoices');
    });
}

function makePayment() {
    const amount = prompt('Enter amount to pay:');
    if (amount) {
        // Redirect to payment gateway
        const username = localStorage.getItem('username');
        const token = localStorage.getItem('token');
        
        fetch(`${API_URL}/api/payment/create`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({
                username: username,
                amount: amount
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.payment_url) {
                window.location.href = data.payment_url;
            } else {
                alert('Payment initiation failed');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Payment initiation failed');
        });
    }
}

function changePackage() {
    const packages = ['5Mbps', '10Mbps', '20Mbps', '50Mbps', '100Mbps'];
    const selected = prompt(
        'Select package:\n' + packages.join('\n')
    );
    
    if (selected && packages.includes(selected)) {
        const username = localStorage.getItem('username');
        const token = localStorage.getItem('token');
        
        fetch(`${API_URL}/api/package/change`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${token}`
            },
            body: JSON.stringify({
                username: username,
                package: selected
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                alert('Package changed successfully');
                loadDashboard();
            } else {
                alert('Package change failed');
            }
        })
        .catch(error => {
            console.error('Error:', error);
            alert('Package change failed');
        });
    }
}

function formatBytes(bytes) {
    if (bytes === 0) return '0 B';
    const k = 1024;
    const sizes = ['B', 'KB', 'MB', 'GB', 'TB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}
7. Reports & Analytics
7.1 Revenue Report
sql
-- Monthly revenue report
SELECT 
    DATE_FORMAT(payment_date, '%Y-%m') as month,
    COUNT(*) as transactions,
    SUM(amount) as total_revenue,
    AVG(amount) as average_payment
FROM payments
WHERE status = 'completed'
GROUP BY DATE_FORMAT(payment_date, '%Y-%m')
ORDER BY month DESC;
7.2 User Growth Report
sql
-- Monthly user growth
SELECT 
    DATE_FORMAT(created_date, '%Y-%m') as month,
    COUNT(*) as new_users,
    COUNT(DISTINCT username) as total_users
FROM user_info
GROUP BY DATE_FORMAT(created_date, '%Y-%m')
ORDER BY month DESC;
7.3 Package Distribution
sql
-- Package distribution
SELECT 
    groupname as package,
    COUNT(*) as users
FROM radusergroup
GROUP BY groupname
ORDER BY users DESC;
<div align="center"> 💰 [Back to Top](#billing-integration-guide) </div> ```