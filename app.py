import pickle
import numpy as np
import pandas as pd
from flask import Flask, request, jsonify, render_template  # Import render_template

# Import required sklearn modules
from sklearn.neighbors import NearestNeighbors  # If using KNN
from sklearn.feature_extraction.text import TfidfVectorizer  # If using TF-IDF

# Load the trained model
with open('model.pkl', 'rb') as f:
    model = pickle.load(f)  # Load KNN model

# Load vectorizer (ensure you saved it earlier)
with open('vectorizer.pkl', 'rb') as f:
    vectorizer = pickle.load(f)

# Load dataset
df = pd.read_csv('processed_recipes - processed_recipes.csv')  # Ensure correct path

# Initialize Flask app
app = Flask(__name__)

# Route for rendering HTML form
@app.route('/')
def index():
    return render_template('index.html')  # Ensure index.html exists in 'templates/'

# Route for handling recipe prediction
@app.route('/predict', methods=['POST'])
def predict():
    ingredients_name = request.form.get('ingredients_name')  # Get input from form

    if not ingredients_name:
        return jsonify({'error': 'Missing ingredients_name parameter'}), 400

    # Convert input to numpy array
    input_query = np.array([ingredients_name])

    # Transform using vectorizer
    input_transformed = vectorizer.transform(input_query)

    # Predict using KNN model
    distances, indices = model.kneighbors(input_transformed)
    recommended_recipes = df.iloc[indices[0]]

    # Extract relevant fields
    results = recommended_recipes[['name', 'ingredients_name', 'image_url', 'description',
                                   'cuisine', 'course', 'diet', 'ingredients_quantity',
                                   'prep_time (in mins)', 'cook_time (in mins)',
                                   'instructions', 'total_time', 'recipe_tags',
                                   'difficulty_level', 'ingredient_category']]

    return jsonify(results.to_dict(orient='records'))  # Return JSON response

# Run Flask app locally
if __name__ == '__main__':
    app.run(debug=True)
