import pickle
import pandas as pd
from flask import Flask,render_template, request
from flask_mysqldb import MySQL
from flask_sqlalchemy import SQLAlchemy

app = Flask(__name__)


with app.app_context(): 
    db = SQLAlchemy()

app.config ['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///DataInputs.db' 

db.init_app(app)

class DataInput(db.Model):
   id = db.Column('case_id', db.Integer, primary_key = True)
   highbp = db.Column(db.Float)
   highchol= db.Column(db.Float)
   cholcheck = db.Column(db.Float)  
   bmi = db.Column(db.Float)
   smoker = db.Column(db.Float)
   stroke = db.Column(db.Float)
   heartdiseaseorattack = db.Column(db.Float)
   physactivity = db.Column(db.Float)
   fruits = db.Column(db.Float)
   veggies = db.Column(db.Float)
   hvyalcoholconsump = db.Column(db.Float)
   anyhealthcare = db.Column(db.Float)
   menthlth = db.Column(db.Float)
   physhlth = db.Column(db.Float)
   diffwalk = db.Column(db.Float)
   sex = db.Column(db.Float)



   def __repr__(self):
        return '<DataInput %r>' % self.highbp

with app.app_context():
    db.create_all()

@app.route('/form')
def form():
    return render_template('DS440_Website_V2.html')
 
@app.route('/results', methods = ['POST', 'GET'])
def results():
    if request.method == 'GET':
        return "Go to /form"
     
    #Function that replaces empty string in html form input with a zero
    def zeros(forms):
        if forms == '':
            forms = 0
            return forms 
        else:
            return forms
    
    if request.method == 'POST':
        addition = DataInput(highbp = zeros(request.form['highbp']), highchol = zeros(request.form['highchol']), cholcheck = zeros(request.form['cholcheck']),  bmi = zeros(request.form['bmi']), smoker = zeros(request.form['smoker']), stroke = zeros(request.form['stroke']), heartdiseaseorattack = zeros(request.form['heartdiseaseorattack']), physactivity = zeros(request.form['physactivity']), fruits = zeros(request.form['fruits']), veggies = zeros(request.form['veggies']), hvyalcoholconsump = zeros(request.form['hvyalcoholconsump']), anyhealthcare = zeros(request.form['anyhealthcare']), menthlth = zeros(request.form['menthlth']), physhlth = zeros(request.form['physhlth']),  diffwalk = zeros(request.form['diffwalk']),  sex = zeros(request.form['sex']))     
        db.session.add(addition)
        db.session.commit()
        
        #Grab data from database to predict on model
        data_query = db.session.query(DataInput).with_entities(DataInput.id, DataInput.highbp, DataInput.highchol, DataInput.cholcheck, DataInput.bmi, DataInput.smoker, DataInput.stroke, DataInput.heartdiseaseorattack, DataInput.physactivity, DataInput.fruits, DataInput.veggies, DataInput.hvyalcoholconsump, DataInput.anyhealthcare, DataInput.menthlth, DataInput.physhlth, DataInput.diffwalk, DataInput.sex)
        inputted_data = data_query.all()
        output_df = pd.DataFrame.from_records(inputted_data, index='id', columns=['id', 'HighBP', 'HighChol', 'CholCheck', 'BMI', 'Smoker', 'Stroke', 'HeartDiseaseorAttack', 'PhysActivity', 'Fruits', 'Veggies', 'HvyAlcoholConsump', 'AnyHealthcare', 'MentHlth', 'PhysHlth', 'DiffWalk', 'Sex'])
        


       
        #delete case from SQL Database
        db.session.delete(addition)
        db.session.commit()
    
        #import in previously trained model
        filename = 'FinalKNNModel.sav'
        PredictionModel = pickle.load(open(filename, 'rb'))

        #Determine liklihood patient has diabetes
        output = PredictionModel.predict_proba(output_df)
        probdiabetes = round(output[0][-1]*100, 2)
        
        #Return Liklihood of diabetes
        if probdiabetes > 75:
            return f"The patient has a {probdiabetes}% liklihood of Diabetes. Since the liklihood is greater than 75%, there is a good chance the patient has diabetes. Further testing should be completed to confirm this result."
        elif probdiabetes > 50:
            return f"The patient has a {probdiabetes}% liklihood of Diabetes. It is likely this patient has diabetes however further testing should be completed to ensure accuracy."
        else:
            return f"The patient has a {probdiabetes}% liklihood of Diabetes. Based on the entered information it is not likely that the patient has diabetes."

app.run(host='localhost', port=5000)



if __name__ == '__main__':
    app.run(debug=True)