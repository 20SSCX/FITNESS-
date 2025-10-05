from flask import Flask, render_template, request, redirect
import sqlite3

app = Flask(__name__)

# Database setup
def init_db():
    conn = sqlite3.connect("fitness.db")
    cur = conn.cursor()
    cur.execute("""
    CREATE TABLE IF NOT EXISTS contacts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        email TEXT,
        message TEXT
    )
    """)
    conn.commit()
    conn.close()

@app.route('/')
def home():
    return render_template("home.html")

@app.route('/about')
def about():
    return render_template("about.html")

@app.route('/services')
def services():
    return render_template("services.html")

@app.route('/contact', methods=["GET", "POST"])
def contact():
    if request.method == "POST":
        name = request.form["name"]
        email = request.form["email"]
        message = request.form["message"]

        conn = sqlite3.connect("fitness.db")
        cur = conn.cursor()
        cur.execute("INSERT INTO contacts (name, email, message) VALUES (?, ?, ?)", 
                    (name, email, message))
        conn.commit()
        conn.close()
        return redirect("/")
    return render_template("contact.html")

@app.route('/bmi', methods=["GET", "POST"])
def bmi():
    bmi_result = None
    if request.method == "POST":
        weight = float(request.form["weight"])
        height = float(request.form["height"]) / 100  # convert cm to meters
        bmi_value = round(weight / (height ** 2), 2)
        if bmi_value < 18.5:
            bmi_result = f"Your BMI is {bmi_value} (Underweight)"
        elif 18.5 <= bmi_value < 24.9:
            bmi_result = f"Your BMI is {bmi_value} (Normal)"
        elif 25 <= bmi_value < 29.9:
            bmi_result = f"Your BMI is {bmi_value} (Overweight)"
        else:
            bmi_result = f"Your BMI is {bmi_value} (Obese)"
    return render_template("bmi.html", result=bmi_result)

if __name__ == "__main__":
    init_db()
    app.run(debug=True)
