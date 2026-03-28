from flask import Flask, request, jsonify
import mysql.connector
from mysql.connector import Error
try:
    from flask_cors import CORS
except Exception:
    # Flask-CORS is not installed or could not be imported; provide a no-op CORS
    def CORS(app, **kwargs):
        # no-op: in development without Flask-CORS this allows the app to run
        return None
from flask_mail import Mail, Message
import random
import string

app = Flask(__name__)
CORS(app)  # allows frontend JS to call backend APIs

# ---------------------------
# Database connection helper
# ---------------------------
def get_connection():
    try:
        connection = mysql.connector.connect(
            host='localhost',
            database='airline_db',
            user='root',          # change if needed
            password='keer@15'  # change this
        )
        return connection
    except Error as e:
        print("Error while connecting to MySQL", e)
        return None
    

# ---------------------------
# Utility: send email (dummy)
# ---------------------------
def send_email(to_email, subject, body):
    try:
        msg = Message(subject, recipients=[to_email])
        msg.body = body
        mail.send(msg)
        print("Email sent to:", to_email)
    except Exception as e:
        print("Email sending failed:", e)


# ---------------------------
# API: Create new booking
# ---------------------------
@app.route('/api/book', methods=['POST'])
def book_ticket():
    import re
    
    data = request.get_json()

    name = data.get('name')
    travel_class = data.get('travel_class')
    ticket_rate = data.get('ticket_rate')
    flight_name = data.get('flight_name')
    aadhaar_no = data.get('aadhaar_no')
    email = data.get('email')

    if not all([name, travel_class, ticket_rate, flight_name, aadhaar_no, email]):
        return jsonify({'success': False, 'message': 'All fields are required'}), 400

    # Aadhaar validation
    aadhaar_pattern = r"^[0-9]{12}$"
    if not re.match(aadhaar_pattern, aadhaar_no):
        return jsonify({'success': False, 'message': 'Invalid Aadhaar number. Must be 12 digits.'}), 400

    conn = get_connection()
    if conn is None:
        return jsonify({'success': False, 'message': 'Database connection failed'}), 500

    try:
        cursor = conn.cursor()
        insert_query = """
            INSERT INTO passengers (name, class, ticket_rate, flight_name, aadhaar_no, email, status)
            VALUES (%s, %s, %s, %s, %s, %s, 'BOOKED')
        """
        cursor.execute(insert_query, (name, travel_class, ticket_rate, flight_name, aadhaar_no, email))
        conn.commit()

        # send email notification (simulated)
        subject = "Flight Booking Confirmed"
        body = f"Dear {name},\n\nYour ticket for flight {flight_name} is successfully BOOKED.\nClass: {travel_class}\nTicket Rate: {ticket_rate}\n\nThank you."
        send_email(email, subject, body)

        return jsonify({'success': True, 'message': 'Booking successful'}), 201
    except Error as e:
        print("Error while inserting:", e)
        return jsonify({'success': False, 'message': 'Failed to book ticket, Aadhaar may already exist'}), 500
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()


# ---------------------------
# API: Get boarding pass
# ---------------------------
@app.route('/api/boarding_pass', methods=['GET'])
def boarding_pass():
    pnr = request.args.get('pnr')
    if not pnr:
        return jsonify({'success': False, 'message': 'PNR is required'}), 400

    conn = get_connection()
    if conn is None:
        return jsonify({'success': False, 'message': 'Database connection failed'}), 500

    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM passengers WHERE pnr = %s", (pnr,))
        passenger = cursor.fetchone()

        if not passenger:
            return jsonify({'success': False, 'message': 'PNR not found'}), 404

        return jsonify({'success': True, 'data': passenger}), 200
    except Error as e:
        print("Error fetching boarding pass:", e)
        return jsonify({'success': False, 'message': 'Failed to fetch boarding pass'}), 500
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()


# ---------------------------
# API: List all passengers
# ---------------------------
@app.route('/api/passengers', methods=['GET'])
def get_passengers():
    conn = get_connection()
    if conn is None:
        return jsonify({'success': False, 'message': 'Database connection failed'}), 500

    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM passengers ORDER BY booking_time DESC")
        rows = cursor.fetchall()
        return jsonify({'success': True, 'data': rows}), 200
    except Error as e:
        print("Error while fetching:", e)
        return jsonify({'success': False, 'message': 'Failed to fetch passengers'}), 500
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()


# ---------------------------
# API: Cancel booking
# ---------------------------
@app.route('/api/cancel', methods=['POST'])
def cancel_ticket():
    data = request.get_json()
    aadhaar_no = data.get('aadhaar_no')

    if not aadhaar_no:
        return jsonify({'success': False, 'message': 'Aadhaar number is required'}), 400

    conn = get_connection()
    if conn is None:
        return jsonify({'success': False, 'message': 'Database connection failed'}), 500

    try:
        cursor = conn.cursor(dictionary=True)
        # find the passenger
        cursor.execute("SELECT * FROM passengers WHERE aadhaar_no = %s", (aadhaar_no,))
        passenger = cursor.fetchone()

        if not passenger:
            return jsonify({'success': False, 'message': 'Passenger not found'}), 404

        # update status
        cursor.execute(
            "UPDATE passengers SET status = 'CANCELLED' WHERE aadhaar_no = %s",
            (aadhaar_no,)
        )
        conn.commit()

        # email notification
        subject = "Flight Booking Cancelled"
        body = f"Dear {passenger['name']},\n\nYour ticket for flight {passenger['flight_name']} has been CANCELLED.\n\nThank you."
        send_email(passenger['email'], subject, body)

        return jsonify({'success': True, 'message': 'Booking cancelled'}), 200
    except Error as e:
        print("Error while cancelling:", e)
        return jsonify({'success': False, 'message': 'Failed to cancel booking'}), 500
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()


# ---------------------------
# API: Search by Aadhaar
# ---------------------------
@app.route('/api/search', methods=['GET'])
def search_passenger():
    aadhaar_no = request.args.get('aadhaar_no')
    if not aadhaar_no:
        return jsonify({'success': False, 'message': 'Aadhaar number is required'}), 400

    conn = get_connection()
    if conn is None:
        return jsonify({'success': False, 'message': 'Database connection failed'}), 500

    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM passengers WHERE aadhaar_no = %s", (aadhaar_no,))
        passenger = cursor.fetchone()

        if not passenger:
            return jsonify({'success': False, 'message': 'Passenger not found'}), 404

        return jsonify({'success': True, 'data': passenger}), 200
    except Error as e:
        print("Error while searching:", e)
        return jsonify({'success': False, 'message': 'Failed to search passenger'}), 500
    finally:
        if conn.is_connected():
            cursor.close()
            conn.close()


app.config['MAIL_SERVER'] = 'smtp.gmail.com'
app.config['MAIL_PORT'] = 587
app.config['MAIL_USE_TLS'] = True
app.config['MAIL_USERNAME'] = 'yourgmail@gmail.com'
app.config['MAIL_PASSWORD'] = 'your_app_password_here'
app.config['MAIL_DEFAULT_SENDER'] = 'yourgmail@gmail.com'

mail = Mail(app)


@app.route('/api/admin/login', methods=['POST'])
def admin_login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT * FROM admins WHERE username=%s AND password=%s", (username, password))
    admin = cursor.fetchone()

    if admin:
        return jsonify({'success': True, 'message': 'Login successful'})
    else:
        return jsonify({'success': False, 'message': 'Invalid credentials'}), 401


@app.route('/api/admin/delete', methods=['POST'])
def admin_delete():
    data = request.get_json()
    aadhaar_no = data.get('aadhaar_no')

    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute("DELETE FROM passengers WHERE aadhaar_no=%s", (aadhaar_no,))
    conn.commit()

    return jsonify({'success': True, 'message': 'Passenger deleted successfully'})
@app.route('/api/stats', methods=['GET'])
def stats():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    cursor.execute("SELECT class, COUNT(*) AS count FROM passengers GROUP BY class")
    class_data = cursor.fetchall()

    cursor.execute("SELECT status, COUNT(*) AS count FROM passengers GROUP BY status")
    status_data = cursor.fetchall()

    return jsonify({
        "class_stats": class_data,
        "status_stats": status_data
    })
def generate_pnr():
    # Example: 6-character alphanumeric PNR
    return ''.join(random.choices(string.ascii_uppercase + string.digits, k=6))

def generate_seat():
    # Example: rows 1–30, seats A–F
    row = random.randint(1, 30)
    seat = random.choice(list("ABCDEF"))
    return f"{row}{seat}"
@app.route("/api/admin/delete", methods=["POST"])
def cancel_booking():
    data = request.get_json()
    aadhaar = data.get("aadhaar_no")
    conn = mysql.connect()
    cursor = conn.cursor()
    cursor.execute("UPDATE bookings SET status='CANCELLED' WHERE aadhaar_no=%s", (aadhaar,))
    conn.commit()
    return jsonify({"success": True})