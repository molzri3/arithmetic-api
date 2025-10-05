from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/add', methods=['POST'])
def add():
    data = request.get_json()
    a = data.get('a', 0)
    b = data.get('b', 0)
    return jsonify({'result': a + b})

@app.route('/subtract', methods=['POST'])
def subtract():
    data = request.get_json()
    a = data.get('a', 0)
    b = data.get('b', 0)
    return jsonify({'result': a - b})

@app.route('/multiply', methods=['POST'])
def multiply():
    data = request.get_json()
    a = data.get('a', 0)
    b = data.get('b', 0)
    return jsonify({'result': a * b})

@app.route('/divide', methods=['POST'])
def divide():
    data = request.get_json()
    a = data.get('a', 0)
    b = data.get('b', 0)
    if b == 0:
        return jsonify({'error': 'Cannot divide by zero'}), 400
    return jsonify({'result': a / b})

@app.route('/health', methods=['GET'])
def health():
    return jsonify({'status': 'healthy'})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
