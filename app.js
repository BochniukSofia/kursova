// app.js

document.addEventListener('DOMContentLoaded', () => {
  const page = document.body.dataset.page;

  if (page === 'home') {
    loadTrips();
  } else if (page === 'seats') {
    loadSeatsPage();
  }
});

// ====== ГОЛОВНА СТОРІНКА: СПИСОК РЕЙСІВ ======

async function loadTrips() {
  const listEl = document.getElementById('trip-list');
  if (!listEl) return;

  try {
    const res = await fetch('/api/trips');
    const trips = await res.json();

    if (!trips.length) {
      listEl.innerHTML = '<p>Наразі немає доступних рейсів.</p>';
      return;
    }

    listEl.innerHTML = '';
    trips.forEach(trip => {
      const card = document.createElement('article');
      card.className = 'trip-card';

      const depTime = new Date(trip.DepartureTime);
      const arrTime = new Date(trip.ArrivalTime);

      card.innerHTML = `
        <h3>${trip.DepartureCity} → ${trip.ArrivalCity}</h3>
        <p class="trip-meta">${formatDate(depTime)} · Відправлення о ${formatTime(depTime)}</p>
        <p class="trip-meta">Прибуття о ${formatTime(arrTime)}</p>
        <p>Автобус: <strong>${trip.Model}</strong></p>
        <a class="button" href="seats.html?tripId=${trip.TripID}">Обрати місце</a>
      `;
      listEl.appendChild(card);
    });
  } catch (err) {
    console.error(err);
    listEl.innerHTML = '<p>Помилка завантаження рейсів.</p>';
  }
}

function formatDate(d) {
  return d.toLocaleDateString('uk-UA', { day: '2-digit', month: '2-digit', year: 'numeric' });
}

function formatTime(d) {
  return d.toLocaleTimeString('uk-UA', { hour: '2-digit', minute: '2-digit' });
}

// ====== СТОРІНКА МІСЦЬ ======

async function loadSeatsPage() {
  const params = new URLSearchParams(window.location.search);
  const tripId = params.get('tripId');

  const grid = document.getElementById('seats-grid');
  const msg = document.getElementById('seat-message');

  if (!tripId || !grid) {
    if (msg) msg.textContent = 'Не вказано ідентифікатор рейсу.';
    return;
  }

  await loadTripHeader(tripId);

  try {
    const res = await fetch(`/api/trips/${tripId}/seats`);
    const seats = await res.json();

    grid.innerHTML = '';

    seats.forEach(seat => {
      const btn = document.createElement('div');
      btn.className = 'seat ' + (seat.IsBooked ? 'seat-booked' : 'seat-free');
      btn.textContent = seat.SeatNumber;
      btn.dataset.seatId = seat.SeatID;
      btn.dataset.booked = seat.IsBooked ? '1' : '0';

      if (!seat.IsBooked) {
        btn.addEventListener('click', () => handleSeatClick(btn, tripId));
      }

      grid.appendChild(btn);
    });
  } catch (err) {
    console.error(err);
    msg.textContent = 'Помилка завантаження місць.';
  }
}

async function loadTripHeader(tripId) {
  try {
    const res = await fetch('/api/trips');
    const trips = await res.json();
    const trip = trips.find(t => t.TripID == tripId);
    if (!trip) return;

    const titleEl = document.getElementById('trip-title');
    const subtitleEl = document.getElementById('trip-subtitle');

    const depTime = new Date(trip.DepartureTime);
    const arrTime = new Date(trip.ArrivalTime);

    if (titleEl) {
      titleEl.textContent = `Рейс: ${trip.DepartureCity} → ${trip.ArrivalCity}`;
    }
    if (subtitleEl) {
      subtitleEl.textContent = `${formatDate(depTime)}, виїзд о ${formatTime(depTime)}, прибуття о ${formatTime(arrTime)}, автобус ${trip.Model}`;
    }
  } catch (err) {
    console.error(err);
  }
}

async function handleSeatClick(btn, tripId) {
  const seatId = btn.dataset.seatId;
  const msg = document.getElementById('seat-message');

  btn.classList.add('seat-selected');
  msg.textContent = 'Виконується бронювання...';

  try {
    const res = await fetch('/api/bookings', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ tripId: Number(tripId), seatId: Number(seatId) })
    });

    if (res.status === 201) {
      btn.classList.remove('seat-selected', 'seat-free');
      btn.classList.add('seat-booked');
      btn.dataset.booked = '1';
      btn.removeEventListener('click', handleSeatClick);
      msg.textContent = `Місце №${btn.textContent} успішно заброньовано.`;
    } else if (res.status === 409) {
      btn.classList.remove('seat-selected');
      msg.textContent = 'Це місце вже заброньоване.';
    } else {
      btn.classList.remove('seat-selected');
      msg.textContent = 'Сталася помилка при бронюванні.';
    }
  } catch (err) {
    console.error(err);
    btn.classList.remove('seat-selected');
    msg.textContent = 'Сталася помилка з’єднання з сервером.';
  }
}
async function initAuthHeader() {
  const authLink = document.getElementById('auth-link');
  if (!authLink) return;

  try {
    const res = await fetch('/api/me');
    const user = await res.json();

    if (user && user.userId) {
      authLink.textContent = `Вийти (${user.fullName})`;
      authLink.href = '#';
      authLink.onclick = async (e) => {
        e.preventDefault();
        await fetch('/api/logout', { method: 'POST' });
        window.location.reload();
      };
    } else {
      authLink.textContent = 'Вхід / Реєстрація';
      authLink.href = 'login.html';
    }
  } catch (e) {
    console.error(e);
  }
}

document.addEventListener('DOMContentLoaded', () => {
  initAuthHeader();
  
});

