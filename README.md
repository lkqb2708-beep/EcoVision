# 🌍 EcoVision 📸
*(Formerly known as Trashy)*

Welcome to **EcoVision**! 🌿✨ This is a super smart camera app that uses **Artificial Intelligence (AI)** 🤖 to look at trash and tell you exactly what kind of waste it is! 

This project is made of two cool parts:
1. **The Mobile App 📱** (Built with Flutter)
2. **The Smart Brain 🧠** (Built with Python, FastAPI, and OpenRouter AI)

---

## 🚀 How It Works (The Magic Behind the App!)

Here is the step-by-step journey of how EcoVision figures out what trash you're looking at:

1. **📸 Snap a Pic!** You open the EcoVision app on your phone and take a picture of a piece of trash.
2. **🪄 Code Magic:** The app changes your picture into a super long secret code (called a *base64 string*) so computers can read it.
3. **🚀 Blast Off to the Server:** The app sends this secret code over the internet to our backend "Brain" (FastAPI server).
4. **🤖 AI Super-Vision:** Our server shows the picture to an AI (OpenRouter Vision). The AI acts like a smart scientist 🧑‍🔬—it looks at the picture and says, *"Aha! That's a plastic bottle! And I'm 95% sure!"*
5. **🗂️ Saving the Data:** The server writes down what it found in a digital notebook (PostgreSQL Database) so we can keep track of all the trash we've found.
6. **🎉 Ta-Da!** The backend sends the answer back to your phone, and the app pops up the result: **"Plastic Bottle!"** 🥤♻️

---

## 📂 Project Setup (Where everything lives)

- 📱 `lib/`: This folder has all the code for the phone app! It's where the buttons, colors, and camera live.
- 🧠 `backend/`: This folder has the Python brain! 
  - 🚦 `main.py`: The traffic cop that takes messages from the app and talks to the AI.
  - 🗄️ `database.py`: The code that talks to our digital notebook.
  - 🤖 `trashy.py`: The script that actually talks to the AI brain!

---

## 🛠️ How to Run the App (For Hackers & Creators!)

Want to run this yourself? Here's how you set it up!

### 1️⃣ Wake Up the Brain (Backend Setup 🧠)

You will need **Python** 🐍 and **PostgreSQL** 🐘 installed.

1. **Open your terminal and go to the backend folder:**
   ```bash
   cd backend
   ```
2. **Create a safe playground (Virtual Environment) and turn it on:**
   ```bash
   python -m venv venv
   # On Windows type:
   venv\Scripts\activate
   # On Mac/Linux type:
   source venv/bin/activate
   ```
3. **Install the super-powered libraries:**
   ```bash
   pip install fastapi uvicorn psycopg2-binary pydantic requests python-dotenv
   ```
4. **Start the Brain! 🚀**
   ```bash
   uvicorn main:app --host 0.0.0.0 --port 8000 --reload
   ```

### 2️⃣ Wake Up the App (Frontend Setup 📱)

You will need the **Flutter SDK** 🐦 installed.

1. **Go to the main project folder:**
   ```bash
   flutter pub get
   ```
2. **Connect the App to the Brain:**
   Make sure the app knows where to find the brain! Open `lib/api_service.dart` and make sure the IP address matches your computer's IP (e.g., `http://192.168.1.5:8000/analyze`).
3. **Run the App! 🎉**
   ```bash
   flutter run
   ```
   *(P.S. Real cameras work best on real phones instead of computer emulators! 📸)*

---

**Let's save the planet, one picture at a time! 🌎♻️💚**
