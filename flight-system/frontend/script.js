const API_BASE = "http://127.0.0.1:5000/api"; // adjust if needed

// Booking form
const bookingForm = document.getElementById("bookingForm");
const bookingMessage = document.getElementById("bookingMessage");

// Manage booking elements
const searchAadhaarInput = document.getElementById("searchAadhaar");
const searchBtn = document.getElementById("searchBtn");
const cancelBtn = document.getElementById("cancelBtn");
const searchResult = document.getElementById("searchResult");

// Passenger list
const passengerTableBody = document.getElementById("passengerTableBody");
const refreshBtn = document.getElementById("refreshBtn");

// Helper to show messages
function showMessage(element, text, type = "") {
    element.textContent = text;
    element.className = "message";
    if (type) {
        element.classList.add(type);
    }
}

// ----------------------
// Booking submission
// ----------------------
bookingForm.addEventListener("submit", async (e) => {
    e.preventDefault();

    const name = document.getElementById("name").value.trim();
    const travel_class = document.getElementById("class").value.trim();
    const ticket_rate = document.getElementById("ticket_rate").value.trim();
    const flight_name = document.getElementById("flight_name").value.trim();
    const aadhaar_no = document.getElementById("aadhaar_no").value.trim();
    const email = document.getElementById("email").value.trim();

    showMessage(bookingMessage, "Booking in progress...", "");

    try {
        const res = await fetch(`${API_BASE}/book`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
                name,
                travel_class,
                ticket_rate,
                flight_name,
                aadhaar_no,
                email
            })
        });

        const data = await res.json();

        if (res.ok && data.success) {
            showMessage(bookingMessage, data.message, "success");
            bookingForm.reset();
            loadPassengers();
        } else {
            showMessage(bookingMessage, data.message || "Booking failed", "error");
        }
    } catch (error) {
        console.error(error);
        showMessage(bookingMessage, "Error connecting to server", "error");
    }
});

// ----------------------
// Load all passengers
// ----------------------
async function loadPassengers() {
    passengerTableBody.innerHTML = `<tr><td colspan="8">Loading...</td></tr>`;
    try {
        const res = await fetch(`${API_BASE}/passengers`);
        const data = await res.json();

        if (!res.ok || !data.success) {
            passengerTableBody.innerHTML = `<tr><td colspan="8">Failed to load passengers</td></tr>`;
            return;
        }

        if (data.data.length === 0) {
            passengerTableBody.innerHTML = `<tr><td colspan="8">No passengers found</td></tr>`;
            return;
        }

        passengerTableBody.innerHTML = "";
        data.data.forEach(p => {
            const tr = document.createElement("tr");

            const statusClass = p.status === "BOOKED" ? "status-booked" : "status-cancelled";

            tr.innerHTML = `
                <td>${p.name}</td>
                <td>${p.class}</td>
                <td>${p.ticket_rate}</td>
                <td>${p.flight_name}</td>
                <td>${p.aadhaar_no}</td>
                <td>${p.email}</td>
                <td class="${statusClass}">${p.status}</td>
                <td>${new Date(p.booking_time).toLocaleString()}</td>
            `;
            passengerTableBody.appendChild(tr);
        });
    } catch (error) {
        console.error(error);
        passengerTableBody.innerHTML = `<tr><td colspan="8">Error connecting to server</td></tr>`;
    }
}

// ----------------------
// Search passenger
// ----------------------
searchBtn.addEventListener("click", async () => {
    const aadhaar = searchAadhaarInput.value.trim();
    if (!aadhaar) {
        showMessage(searchResult, "Please enter Aadhaar number", "error");
        return;
    }

    showMessage(searchResult, "Searching...", "");

    try {
        const res = await fetch(`${API_BASE}/search?aadhaar_no=${encodeURIComponent(aadhaar)}`);
        const data = await res.json();

        if (res.ok && data.success) {
            const p = data.data;
            showMessage(
                searchResult,
                `Found: ${p.name}, ${p.class} class, Flight ${p.flight_name}, Status: ${p.status}`,
                "success"
            );
        } else {
            showMessage(searchResult, data.message || "Passenger not found", "error");
        }
    } catch (error) {
        console.error(error);
        showMessage(searchResult, "Error connecting to server", "error");
    }
});// Simple route guards: require admin for dashboard
if (location.pathname.endsWith('admin_dashboard.html')) {
  if (!localStorage.getItem('admin')) {
    location.href = 'admin_login.html';
  }
}

// Buttons
document.getElementById('startBookingBtn')?.addEventListener('click', () => {
  location.href = 'user.html';
});

document.getElementById('logoutLink')?.addEventListener('click', (e) => {
  e.preventDefault();
  localStorage.removeItem('admin');
  location.href = 'admin_login.html';
});

// Search flights preview (frontend-only placeholder)
document.getElementById('searchBtn')?.addEventListener('click', () => {
  const from = document.getElementById('fromCity').value || 'Chennai (MAA)';
  const to = document.getElementById('toCity').value || 'Delhi (DEL)';
  const depart = document.getElementById('departDate').value || '(choose date)';
  const ret = document.getElementById('returnDate').value || '(optional)';
  const cls = document.getElementById('travelClass').value || 'Economy';

  alert(`Searching flights:\n${from} → ${to}\nDepart: ${depart}\nReturn: ${ret}\nClass: ${cls}`);
  // Hook to backend here, e.g.:
  // fetch('http://127.0.0.1:5000/api/search_flights?...')
});

// ----------------------
// Cancel booking
// ----------------------
cancelBtn.addEventListener("click", async () => {
    const aadhaar = searchAadhaarInput.value.trim();
    if (!aadhaar) {
        showMessage(searchResult, "Please enter Aadhaar number to cancel", "error");
        return;
    }

    if (!confirm("Are you sure you want to cancel this booking?")) {
        return;
    }

    showMessage(searchResult, "Cancelling...", "");

    try {
        const res = await fetch(`${API_BASE}/cancel`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({ aadhaar_no: aadhaar })
        });

        const data = await res.json();

        if (res.ok && data.success) {
            showMessage(searchResult, data.message, "success");
            loadPassengers();
        } else {
            showMessage(searchResult, data.message || "Cancellation failed", "error");
        }
    } catch (error) {
        console.error(error);
        showMessage(searchResult, "Error connecting to server", "error");
    }
});

// Initial load
window.addEventListener("DOMContentLoaded", loadPassengers);

// ----------------------
// Logout function
// ----------------------
function logout() {
  localStorage.removeItem("admin");
  window.location.href = "admin_login.html";
}

// ----------------------
// QR generation
// ----------------------
function downloadQR() {
  const canvas = document.getElementById("qrCanvas");
  const link = document.createElement("a");
  link.download = "boarding-pass.png";
  link.href = canvas.toDataURL("image/png");
  link.click();
}

// ----------------------
// Example Chart.js setup
// ----------------------
const ctx = document.getElementById('bookingChart')?.getContext('2d');
if (ctx) {
  const bookingChart = new Chart(ctx, {
    type: 'bar',
    data: {
      labels: ['Bookings'],
      datasets: [{
        label: 'Flight Bookings',
        data: [0],
        backgroundColor: 'rgba(75, 192, 192, 0.2)',
        borderColor: 'rgba(75, 192, 192, 1)',
        borderWidth: 1
      }]
    },
    options: {
      responsive: true,
      scales: {
        y: {
          beginAtZero: true
        }
      }
    }
  });
}
function bookFlight() {
  const name = document.getElementById("name").value.trim();
  const dob = document.getElementById("dob").value;
  const aadhaar = document.getElementById("aadhaar").value.trim();
  const phone = document.getElementById("phone").value.trim();
  const email = document.getElementById("email").value.trim();

  // Validation
  if (!name || !dob || !aadhaar || !phone || !email) {
    alert("Please fill in all fields.");
    return;
  }
  if (!/^[0-9]{12}$/.test(aadhaar)) {
    alert("Aadhaar number must be exactly 12 digits.");
    return;
  }
  if (!/^[0-9]{10}$/.test(phone)) {
    alert("Phone number must be exactly 10 digits.");
    return;
  }
  if (!/^[^\\s@]+@[^\\s@]+\\.[^\\s@]+$/.test(email)) {
    alert("Please enter a valid email address.");
    return;
  }

  // Proceed with booking
  const booking = {
    name, dob, aadhaar, phone, email,
    from: document.getElementById("fromCity").value,
    to: document.getElementById("toCity").value,
    depart: document.getElementById("departDate").value,
    return: document.getElementById("returnDate").value,
    travelClass: document.getElementById("travelClass").value
  };

  alert(`Booking confirmed for ${name} (PNR: SAS${Math.floor(100000 + Math.random() * 900000)})`);
  // TODO: send to backend via fetch('/api/book', {method:'POST', body: JSON.stringify(booking)})
}
function cancelBooking(pnr, aadhaar) {
  if (!confirm(`Cancel booking for PNR ${pnr}?`)) return;

  fetch("http://127.0.0.1:5000/api/admin/delete", {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify({ aadhaar_no: aadhaar })
  })
  .then(res => res.json())
  .then(json => {
    if (json.success) {
      alert("Booking cancelled.");
      // Optionally remove row from table
      location.reload();
    } else {
      alert("Cancellation failed.");
    }
  });
}
function filterStatus(status) {
  // TODO: fetch filtered bookings from backend
  alert(`Filtering by status: ${status}`);
}