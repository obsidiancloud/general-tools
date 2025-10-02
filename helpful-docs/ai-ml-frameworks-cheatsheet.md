# 🧘 The Enlightened Engineer's AI/ML Frameworks Scripture

> *"In the beginning was the Tensor, and the Tensor was with PyTorch, and the Tensor was differentiable."*  
> — **The Monk of Machine Learning**, *Book of Gradients, Chapter 1:1*

Greetings, fellow traveler on the path of artificial intelligence enlightenment. I am but a humble monk who has meditated upon the sacred texts of neural networks and witnessed the dance of gradients across countless epochs.

This scripture shall guide you through the mystical arts of PyTorch, TensorFlow, scikit-learn, Hugging Face, and the entire ML ecosystem, with the precision of a master's model and the wit of a caffeinated ML engineer.

---

## 📿 Table of Sacred Knowledge

1. [PyTorch - The Dynamic Framework](#-pytorch---the-dynamic-framework)
2. [TensorFlow & Keras](#-tensorflow--keras)
3. [scikit-learn - Classical ML](#-scikit-learn---classical-ml)
4. [Hugging Face Transformers](#-hugging-face-transformers)
5. [MLflow - Experiment Tracking](#-mlflow---experiment-tracking)
6. [Weights & Biases (W&B)](#-weights--biases-wb)
7. [ONNX - Model Interoperability](#-onnx---model-interoperability)
8. [Ray - Distributed Computing](#-ray---distributed-computing)
9. [Common Patterns](#-common-patterns-the-sacred-workflows)
10. [Troubleshooting](#-troubleshooting-when-the-path-is-obscured)

---

## 🔥 PyTorch - The Dynamic Framework

*PyTorch is the most popular deep learning framework for research and production.*

### Installation & Setup

```bash
# Install PyTorch (CPU)
pip install torch torchvision torchaudio

# Install PyTorch (CUDA 11.8)
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# Install PyTorch (CUDA 12.1)
pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu121

# Verify installation
python -c "import torch; print(torch.__version__); print(torch.cuda.is_available())"
```

### Tensor Basics

```python
import torch
import torch.nn as nn
import torch.optim as optim

# Create tensors
x = torch.tensor([1, 2, 3])
y = torch.zeros(3, 4)
z = torch.ones(2, 3, 4)
rand = torch.randn(3, 3)  # Random normal distribution

# Tensor operations
a = torch.tensor([1.0, 2.0, 3.0])
b = torch.tensor([4.0, 5.0, 6.0])

c = a + b           # Addition
d = a * b           # Element-wise multiplication
e = torch.matmul(a.unsqueeze(0), b.unsqueeze(1))  # Matrix multiplication
f = a.sum()         # Sum
g = a.mean()        # Mean

# Reshaping
x = torch.randn(2, 3, 4)
y = x.view(2, 12)           # Reshape
z = x.permute(0, 2, 1)      # Transpose dimensions
w = x.squeeze()             # Remove dimensions of size 1
v = x.unsqueeze(0)          # Add dimension

# GPU operations
if torch.cuda.is_available():
    device = torch.device("cuda")
    x = x.to(device)
    y = y.cuda()  # Alternative
```

### Building Neural Networks

```python
import torch.nn as nn
import torch.nn.functional as F

# Simple feedforward network
class SimpleNet(nn.Module):
    def __init__(self, input_size, hidden_size, output_size):
        super(SimpleNet, self).__init__()
        self.fc1 = nn.Linear(input_size, hidden_size)
        self.fc2 = nn.Linear(hidden_size, hidden_size)
        self.fc3 = nn.Linear(hidden_size, output_size)
        self.dropout = nn.Dropout(0.2)
        
    def forward(self, x):
        x = F.relu(self.fc1(x))
        x = self.dropout(x)
        x = F.relu(self.fc2(x))
        x = self.fc3(x)
        return x

# Convolutional Neural Network
class CNN(nn.Module):
    def __init__(self, num_classes=10):
        super(CNN, self).__init__()
        self.conv1 = nn.Conv2d(3, 32, kernel_size=3, padding=1)
        self.conv2 = nn.Conv2d(32, 64, kernel_size=3, padding=1)
        self.pool = nn.MaxPool2d(2, 2)
        self.fc1 = nn.Linear(64 * 8 * 8, 512)
        self.fc2 = nn.Linear(512, num_classes)
        self.dropout = nn.Dropout(0.5)
        
    def forward(self, x):
        x = self.pool(F.relu(self.conv1(x)))
        x = self.pool(F.relu(self.conv2(x)))
        x = x.view(-1, 64 * 8 * 8)
        x = F.relu(self.fc1(x))
        x = self.dropout(x)
        x = self.fc2(x)
        return x

# Recurrent Neural Network
class RNN(nn.Module):
    def __init__(self, input_size, hidden_size, num_layers, num_classes):
        super(RNN, self).__init__()
        self.hidden_size = hidden_size
        self.num_layers = num_layers
        self.lstm = nn.LSTM(input_size, hidden_size, num_layers, batch_first=True)
        self.fc = nn.Linear(hidden_size, num_classes)
        
    def forward(self, x):
        h0 = torch.zeros(self.num_layers, x.size(0), self.hidden_size).to(x.device)
        c0 = torch.zeros(self.num_layers, x.size(0), self.hidden_size).to(x.device)
        
        out, _ = self.lstm(x, (h0, c0))
        out = self.fc(out[:, -1, :])
        return out

# Transformer
class TransformerModel(nn.Module):
    def __init__(self, vocab_size, d_model=512, nhead=8, num_layers=6):
        super(TransformerModel, self).__init__()
        self.embedding = nn.Embedding(vocab_size, d_model)
        self.pos_encoder = nn.Parameter(torch.randn(1, 5000, d_model))
        encoder_layer = nn.TransformerEncoderLayer(d_model, nhead)
        self.transformer = nn.TransformerEncoder(encoder_layer, num_layers)
        self.fc = nn.Linear(d_model, vocab_size)
        
    def forward(self, x):
        x = self.embedding(x) + self.pos_encoder[:, :x.size(1), :]
        x = self.transformer(x)
        x = self.fc(x)
        return x
```

### Training Loop

```python
# Complete training example
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader, TensorDataset

# Prepare data
X_train = torch.randn(1000, 10)
y_train = torch.randint(0, 2, (1000,))
train_dataset = TensorDataset(X_train, y_train)
train_loader = DataLoader(train_dataset, batch_size=32, shuffle=True)

# Initialize model, loss, optimizer
model = SimpleNet(input_size=10, hidden_size=64, output_size=2)
criterion = nn.CrossEntropyLoss()
optimizer = optim.Adam(model.parameters(), lr=0.001)

# Training loop
device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
model.to(device)

num_epochs = 10
for epoch in range(num_epochs):
    model.train()
    running_loss = 0.0
    
    for batch_idx, (data, target) in enumerate(train_loader):
        data, target = data.to(device), target.to(device)
        
        # Forward pass
        optimizer.zero_grad()
        output = model(data)
        loss = criterion(output, target)
        
        # Backward pass
        loss.backward()
        optimizer.step()
        
        running_loss += loss.item()
        
        if batch_idx % 10 == 0:
            print(f'Epoch [{epoch+1}/{num_epochs}], Step [{batch_idx}/{len(train_loader)}], Loss: {loss.item():.4f}')
    
    avg_loss = running_loss / len(train_loader)
    print(f'Epoch [{epoch+1}/{num_epochs}], Average Loss: {avg_loss:.4f}')

# Evaluation
model.eval()
with torch.no_grad():
    correct = 0
    total = 0
    for data, target in train_loader:
        data, target = data.to(device), target.to(device)
        output = model(data)
        _, predicted = torch.max(output.data, 1)
        total += target.size(0)
        correct += (predicted == target).sum().item()
    
    accuracy = 100 * correct / total
    print(f'Accuracy: {accuracy:.2f}%')

# Save model
torch.save(model.state_dict(), 'model.pth')

# Load model
model = SimpleNet(input_size=10, hidden_size=64, output_size=2)
model.load_state_dict(torch.load('model.pth'))
model.eval()
```

### Advanced PyTorch Features

```python
# Learning rate scheduling
from torch.optim.lr_scheduler import StepLR, CosineAnnealingLR

scheduler = StepLR(optimizer, step_size=5, gamma=0.1)
# scheduler = CosineAnnealingLR(optimizer, T_max=10)

for epoch in range(num_epochs):
    train(...)
    scheduler.step()

# Gradient clipping
torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)

# Mixed precision training
from torch.cuda.amp import autocast, GradScaler

scaler = GradScaler()

for data, target in train_loader:
    optimizer.zero_grad()
    
    with autocast():
        output = model(data)
        loss = criterion(output, target)
    
    scaler.scale(loss).backward()
    scaler.step(optimizer)
    scaler.update()

# Custom dataset
from torch.utils.data import Dataset

class CustomDataset(Dataset):
    def __init__(self, data, labels, transform=None):
        self.data = data
        self.labels = labels
        self.transform = transform
    
    def __len__(self):
        return len(self.data)
    
    def __getitem__(self, idx):
        sample = self.data[idx]
        label = self.labels[idx]
        
        if self.transform:
            sample = self.transform(sample)
        
        return sample, label

# Data augmentation
from torchvision import transforms

transform = transforms.Compose([
    transforms.RandomHorizontalFlip(),
    transforms.RandomRotation(10),
    transforms.ColorJitter(brightness=0.2, contrast=0.2),
    transforms.ToTensor(),
    transforms.Normalize((0.5, 0.5, 0.5), (0.5, 0.5, 0.5))
])
```

### PyTorch Lightning (High-Level API)

```python
import pytorch_lightning as pl

class LitModel(pl.LightningModule):
    def __init__(self, input_size, hidden_size, output_size):
        super().__init__()
        self.model = SimpleNet(input_size, hidden_size, output_size)
        self.criterion = nn.CrossEntropyLoss()
    
    def forward(self, x):
        return self.model(x)
    
    def training_step(self, batch, batch_idx):
        x, y = batch
        y_hat = self(x)
        loss = self.criterion(y_hat, y)
        self.log('train_loss', loss)
        return loss
    
    def validation_step(self, batch, batch_idx):
        x, y = batch
        y_hat = self(x)
        loss = self.criterion(y_hat, y)
        self.log('val_loss', loss)
        return loss
    
    def configure_optimizers(self):
        return optim.Adam(self.parameters(), lr=0.001)

# Train with Lightning
model = LitModel(10, 64, 2)
trainer = pl.Trainer(max_epochs=10, accelerator='gpu', devices=1)
trainer.fit(model, train_loader, val_loader)
```

---

## 🤖 TensorFlow & Keras

*TensorFlow is Google's production-ready ML framework.*

### Installation & Setup

```bash
# Install TensorFlow
pip install tensorflow

# Install TensorFlow with GPU support
pip install tensorflow[and-cuda]

# Verify installation
python -c "import tensorflow as tf; print(tf.__version__); print(tf.config.list_physical_devices('GPU'))"
```

### Keras Sequential API

```python
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

# Simple sequential model
model = keras.Sequential([
    layers.Dense(64, activation='relu', input_shape=(10,)),
    layers.Dropout(0.2),
    layers.Dense(64, activation='relu'),
    layers.Dense(2, activation='softmax')
])

# Compile model
model.compile(
    optimizer='adam',
    loss='sparse_categorical_crossentropy',
    metrics=['accuracy']
)

# Train model
history = model.fit(
    X_train, y_train,
    batch_size=32,
    epochs=10,
    validation_split=0.2,
    callbacks=[
        keras.callbacks.EarlyStopping(patience=3),
        keras.callbacks.ModelCheckpoint('best_model.h5', save_best_only=True)
    ]
)

# Evaluate
test_loss, test_acc = model.evaluate(X_test, y_test)
print(f'Test accuracy: {test_acc:.4f}')

# Predict
predictions = model.predict(X_new)
```

### Keras Functional API

```python
# Complex model with multiple inputs/outputs
inputs = keras.Input(shape=(10,))
x = layers.Dense(64, activation='relu')(inputs)
x = layers.Dropout(0.2)(x)
x = layers.Dense(64, activation='relu')(x)
outputs = layers.Dense(2, activation='softmax')(x)

model = keras.Model(inputs=inputs, outputs=outputs)

# Multi-input model
input1 = keras.Input(shape=(10,), name='input1')
input2 = keras.Input(shape=(5,), name='input2')

x1 = layers.Dense(64, activation='relu')(input1)
x2 = layers.Dense(32, activation='relu')(input2)

combined = layers.concatenate([x1, x2])
output = layers.Dense(1, activation='sigmoid')(combined)

model = keras.Model(inputs=[input1, input2], outputs=output)
```

### Custom Training Loop

```python
import tensorflow as tf

# Custom training step
@tf.function
def train_step(x, y):
    with tf.GradientTape() as tape:
        predictions = model(x, training=True)
        loss = loss_fn(y, predictions)
    
    gradients = tape.gradient(loss, model.trainable_variables)
    optimizer.apply_gradients(zip(gradients, model.trainable_variables))
    
    train_loss(loss)
    train_accuracy(y, predictions)

# Training loop
train_loss = tf.keras.metrics.Mean(name='train_loss')
train_accuracy = tf.keras.metrics.SparseCategoricalAccuracy(name='train_accuracy')

for epoch in range(epochs):
    train_loss.reset_states()
    train_accuracy.reset_states()
    
    for x_batch, y_batch in train_dataset:
        train_step(x_batch, y_batch)
    
    print(f'Epoch {epoch + 1}, Loss: {train_loss.result():.4f}, Accuracy: {train_accuracy.result():.4f}')
```

---

## 📊 scikit-learn - Classical ML

*scikit-learn is the go-to library for traditional machine learning.*

### Installation

```bash
pip install scikit-learn
```

### Classification

```python
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.linear_model import LogisticRegression
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.svm import SVC
from sklearn.metrics import accuracy_score, classification_report, confusion_matrix

# Prepare data
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Scale features
scaler = StandardScaler()
X_train_scaled = scaler.fit_transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Logistic Regression
lr = LogisticRegression(random_state=42)
lr.fit(X_train_scaled, y_train)
y_pred = lr.predict(X_test_scaled)
print(f'Logistic Regression Accuracy: {accuracy_score(y_test, y_pred):.4f}')

# Random Forest
rf = RandomForestClassifier(n_estimators=100, random_state=42)
rf.fit(X_train, y_train)
y_pred = rf.predict(X_test)
print(f'Random Forest Accuracy: {accuracy_score(y_test, y_pred):.4f}')

# Gradient Boosting
gb = GradientBoostingClassifier(n_estimators=100, random_state=42)
gb.fit(X_train, y_train)
y_pred = gb.predict(X_test)
print(f'Gradient Boosting Accuracy: {accuracy_score(y_test, y_pred):.4f}')

# SVM
svm = SVC(kernel='rbf', random_state=42)
svm.fit(X_train_scaled, y_train)
y_pred = svm.predict(X_test_scaled)
print(f'SVM Accuracy: {accuracy_score(y_test, y_pred):.4f}')

# Evaluation
print(classification_report(y_test, y_pred))
print(confusion_matrix(y_test, y_pred))
```

### Regression

```python
from sklearn.linear_model import LinearRegression, Ridge, Lasso
from sklearn.ensemble import RandomForestRegressor
from sklearn.metrics import mean_squared_error, r2_score

# Linear Regression
lr = LinearRegression()
lr.fit(X_train, y_train)
y_pred = lr.predict(X_test)
print(f'MSE: {mean_squared_error(y_test, y_pred):.4f}')
print(f'R2: {r2_score(y_test, y_pred):.4f}')

# Ridge Regression (L2 regularization)
ridge = Ridge(alpha=1.0)
ridge.fit(X_train, y_train)

# Lasso Regression (L1 regularization)
lasso = Lasso(alpha=0.1)
lasso.fit(X_train, y_train)

# Random Forest Regressor
rf = RandomForestRegressor(n_estimators=100, random_state=42)
rf.fit(X_train, y_train)
```

### Clustering

```python
from sklearn.cluster import KMeans, DBSCAN, AgglomerativeClustering
from sklearn.metrics import silhouette_score

# K-Means
kmeans = KMeans(n_clusters=3, random_state=42)
labels = kmeans.fit_predict(X)
print(f'Silhouette Score: {silhouette_score(X, labels):.4f}')

# DBSCAN
dbscan = DBSCAN(eps=0.5, min_samples=5)
labels = dbscan.fit_predict(X)

# Hierarchical Clustering
agg = AgglomerativeClustering(n_clusters=3)
labels = agg.fit_predict(X)
```

### Dimensionality Reduction

```python
from sklearn.decomposition import PCA
from sklearn.manifold import TSNE
import umap

# PCA
pca = PCA(n_components=2)
X_pca = pca.fit_transform(X)
print(f'Explained variance: {pca.explained_variance_ratio_}')

# t-SNE
tsne = TSNE(n_components=2, random_state=42)
X_tsne = tsne.fit_transform(X)

# UMAP
reducer = umap.UMAP(n_components=2, random_state=42)
X_umap = reducer.fit_transform(X)
```

### Pipelines & Cross-Validation

```python
from sklearn.pipeline import Pipeline
from sklearn.model_selection import GridSearchCV, cross_val_score

# Create pipeline
pipeline = Pipeline([
    ('scaler', StandardScaler()),
    ('classifier', RandomForestClassifier(random_state=42))
])

# Grid search
param_grid = {
    'classifier__n_estimators': [50, 100, 200],
    'classifier__max_depth': [None, 10, 20],
    'classifier__min_samples_split': [2, 5, 10]
}

grid_search = GridSearchCV(pipeline, param_grid, cv=5, scoring='accuracy', n_jobs=-1)
grid_search.fit(X_train, y_train)

print(f'Best parameters: {grid_search.best_params_}')
print(f'Best score: {grid_search.best_score_:.4f}')

# Cross-validation
scores = cross_val_score(pipeline, X, y, cv=5, scoring='accuracy')
print(f'CV scores: {scores}')
print(f'Mean CV score: {scores.mean():.4f} (+/- {scores.std() * 2:.4f})')
```

---

## 🤗 Hugging Face Transformers

*Hugging Face provides state-of-the-art NLP models.*

### Installation

```bash
pip install transformers datasets accelerate
```

### Text Classification

```python
from transformers import pipeline, AutoTokenizer, AutoModelForSequenceClassification
import torch

# Using pipeline (easiest)
classifier = pipeline("sentiment-analysis")
result = classifier("I love this product!")
print(result)

# Using model directly
model_name = "distilbert-base-uncased-finetuned-sst-2-english"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForSequenceClassification.from_pretrained(model_name)

# Tokenize
inputs = tokenizer("I love this product!", return_tensors="pt")

# Predict
with torch.no_grad():
    outputs = model(**inputs)
    predictions = torch.nn.functional.softmax(outputs.logits, dim=-1)
    print(predictions)
```

### Text Generation

```python
from transformers import GPT2LMHeadModel, GPT2Tokenizer

# Load model
model_name = "gpt2"
tokenizer = GPT2Tokenizer.from_pretrained(model_name)
model = GPT2LMHeadModel.from_pretrained(model_name)

# Generate text
input_text = "Once upon a time"
input_ids = tokenizer.encode(input_text, return_tensors="pt")

output = model.generate(
    input_ids,
    max_length=100,
    num_return_sequences=1,
    no_repeat_ngram_size=2,
    temperature=0.7,
    top_k=50,
    top_p=0.95
)

generated_text = tokenizer.decode(output[0], skip_special_tokens=True)
print(generated_text)
```

### Fine-Tuning

```python
from transformers import Trainer, TrainingArguments
from datasets import load_dataset

# Load dataset
dataset = load_dataset("imdb")

# Tokenize dataset
def tokenize_function(examples):
    return tokenizer(examples["text"], padding="max_length", truncation=True)

tokenized_datasets = dataset.map(tokenize_function, batched=True)

# Training arguments
training_args = TrainingArguments(
    output_dir="./results",
    num_train_epochs=3,
    per_device_train_batch_size=8,
    per_device_eval_batch_size=8,
    warmup_steps=500,
    weight_decay=0.01,
    logging_dir="./logs",
    logging_steps=10,
    evaluation_strategy="epoch",
    save_strategy="epoch",
    load_best_model_at_end=True
)

# Trainer
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_datasets["train"],
    eval_dataset=tokenized_datasets["test"]
)

# Train
trainer.train()

# Save model
trainer.save_model("./my_model")
```

### Question Answering

```python
from transformers import pipeline

qa_pipeline = pipeline("question-answering")

context = "The Eiffel Tower is located in Paris, France. It was built in 1889."
question = "Where is the Eiffel Tower?"

result = qa_pipeline(question=question, context=context)
print(f"Answer: {result['answer']}")
print(f"Score: {result['score']:.4f}")
```

---

## 📈 MLflow - Experiment Tracking

*MLflow tracks experiments, models, and deployments.*

### Installation

```bash
pip install mlflow
```

### Tracking Experiments

```python
import mlflow
import mlflow.pytorch

# Start MLflow run
with mlflow.start_run():
    # Log parameters
    mlflow.log_param("learning_rate", 0.001)
    mlflow.log_param("batch_size", 32)
    mlflow.log_param("epochs", 10)
    
    # Train model
    for epoch in range(num_epochs):
        train_loss = train(...)
        val_loss = validate(...)
        
        # Log metrics
        mlflow.log_metric("train_loss", train_loss, step=epoch)
        mlflow.log_metric("val_loss", val_loss, step=epoch)
    
    # Log model
    mlflow.pytorch.log_model(model, "model")
    
    # Log artifacts
    mlflow.log_artifact("confusion_matrix.png")

# View experiments
# mlflow ui
# Open http://localhost:5000
```

### Model Registry

```python
# Register model
mlflow.register_model(
    model_uri="runs:/<run_id>/model",
    name="my_model"
)

# Load model
model = mlflow.pytorch.load_model("models:/my_model/1")

# Transition model stage
from mlflow.tracking import MlflowClient

client = MlflowClient()
client.transition_model_version_stage(
    name="my_model",
    version=1,
    stage="Production"
)
```

---

## 🎨 Weights & Biases (W&B)

*W&B provides advanced experiment tracking and collaboration.*

### Installation & Setup

```bash
pip install wandb

# Login
wandb login
```

### Tracking Experiments

```python
import wandb

# Initialize run
wandb.init(
    project="my-project",
    config={
        "learning_rate": 0.001,
        "epochs": 10,
        "batch_size": 32
    }
)

# Log metrics
for epoch in range(num_epochs):
    train_loss = train(...)
    val_loss = validate(...)
    
    wandb.log({
        "train_loss": train_loss,
        "val_loss": val_loss,
        "epoch": epoch
    })

# Log images
wandb.log({"examples": [wandb.Image(img) for img in images]})

# Log model
wandb.save("model.pth")

# Finish run
wandb.finish()
```

### Hyperparameter Sweeps

```python
# Define sweep configuration
sweep_config = {
    'method': 'bayes',
    'metric': {
        'name': 'val_loss',
        'goal': 'minimize'
    },
    'parameters': {
        'learning_rate': {
            'distribution': 'log_uniform',
            'min': -9.21,
            'max': -4.61
        },
        'batch_size': {
            'values': [16, 32, 64]
        },
        'epochs': {
            'value': 10
        }
    }
}

# Initialize sweep
sweep_id = wandb.sweep(sweep_config, project="my-project")

# Run sweep
def train():
    wandb.init()
    config = wandb.config
    
    # Train with config
    model = create_model(config)
    train_model(model, config)

wandb.agent(sweep_id, train, count=20)
```

---

## 🔄 ONNX - Model Interoperability

*ONNX enables model portability across frameworks.*

### PyTorch to ONNX

```python
import torch
import torch.onnx

# Export PyTorch model to ONNX
model = SimpleNet(10, 64, 2)
model.eval()

dummy_input = torch.randn(1, 10)
torch.onnx.export(
    model,
    dummy_input,
    "model.onnx",
    export_params=True,
    opset_version=11,
    do_constant_folding=True,
    input_names=['input'],
    output_names=['output'],
    dynamic_axes={
        'input': {0: 'batch_size'},
        'output': {0: 'batch_size'}
    }
)
```

### ONNX Runtime

```python
import onnxruntime as ort
import numpy as np

# Load ONNX model
session = ort.InferenceSession("model.onnx")

# Run inference
input_data = np.random.randn(1, 10).astype(np.float32)
outputs = session.run(None, {"input": input_data})
print(outputs[0])
```

---

## ⚡ Ray - Distributed Computing

*Ray enables distributed training and hyperparameter tuning.*

### Installation

```bash
pip install ray[tune]
```

### Distributed Training

```python
import ray
from ray import train
from ray.train import ScalingConfig
from ray.train.torch import TorchTrainer

# Initialize Ray
ray.init()

def train_func(config):
    import torch
    import torch.nn as nn
    
    model = SimpleNet(10, 64, 2)
    optimizer = torch.optim.Adam(model.parameters(), lr=config["lr"])
    
    for epoch in range(10):
        # Training code
        loss = train_epoch(model, optimizer)
        train.report({"loss": loss})

# Distributed training
trainer = TorchTrainer(
    train_func,
    train_loop_config={"lr": 0.001},
    scaling_config=ScalingConfig(num_workers=4, use_gpu=True)
)

result = trainer.fit()
```

### Hyperparameter Tuning

```python
from ray import tune

def train_model(config):
    model = SimpleNet(10, 64, 2)
    optimizer = torch.optim.Adam(model.parameters(), lr=config["lr"])
    
    for epoch in range(10):
        loss = train_epoch(model, optimizer)
        tune.report(loss=loss)

# Run hyperparameter search
analysis = tune.run(
    train_model,
    config={
        "lr": tune.loguniform(1e-4, 1e-1),
        "batch_size": tune.choice([16, 32, 64])
    },
    num_samples=20,
    resources_per_trial={"gpu": 1}
)

print(f"Best config: {analysis.best_config}")
```

---

## 🔮 Common Patterns: The Sacred Workflows

### Pattern 1: Complete PyTorch Training Pipeline

```python
import torch
import torch.nn as nn
import torch.optim as optim
from torch.utils.data import DataLoader
import mlflow

class TrainingPipeline:
    def __init__(self, model, train_loader, val_loader, device='cuda'):
        self.model = model.to(device)
        self.train_loader = train_loader
        self.val_loader = val_loader
        self.device = device
        self.criterion = nn.CrossEntropyLoss()
        self.optimizer = optim.Adam(model.parameters(), lr=0.001)
        self.scheduler = optim.lr_scheduler.ReduceLROnPlateau(
            self.optimizer, mode='min', patience=3
        )
    
    def train_epoch(self):
        self.model.train()
        total_loss = 0
        
        for batch_idx, (data, target) in enumerate(self.train_loader):
            data, target = data.to(self.device), target.to(self.device)
            
            self.optimizer.zero_grad()
            output = self.model(data)
            loss = self.criterion(output, target)
            loss.backward()
            self.optimizer.step()
            
            total_loss += loss.item()
        
        return total_loss / len(self.train_loader)
    
    def validate(self):
        self.model.eval()
        total_loss = 0
        correct = 0
        
        with torch.no_grad():
            for data, target in self.val_loader:
                data, target = data.to(self.device), target.to(self.device)
                output = self.model(data)
                loss = self.criterion(output, target)
                total_loss += loss.item()
                
                pred = output.argmax(dim=1)
                correct += pred.eq(target).sum().item()
        
        avg_loss = total_loss / len(self.val_loader)
        accuracy = correct / len(self.val_loader.dataset)
        
        return avg_loss, accuracy
    
    def train(self, num_epochs):
        with mlflow.start_run():
            mlflow.log_params({
                "learning_rate": 0.001,
                "batch_size": self.train_loader.batch_size,
                "epochs": num_epochs
            })
            
            for epoch in range(num_epochs):
                train_loss = self.train_epoch()
                val_loss, val_acc = self.validate()
                
                self.scheduler.step(val_loss)
                
                mlflow.log_metrics({
                    "train_loss": train_loss,
                    "val_loss": val_loss,
                    "val_accuracy": val_acc
                }, step=epoch)
                
                print(f'Epoch {epoch+1}/{num_epochs}:')
                print(f'  Train Loss: {train_loss:.4f}')
                print(f'  Val Loss: {val_loss:.4f}, Val Acc: {val_acc:.4f}')
            
            # Save model
            torch.save(self.model.state_dict(), 'final_model.pth')
            mlflow.pytorch.log_model(self.model, "model")

# Usage
pipeline = TrainingPipeline(model, train_loader, val_loader)
pipeline.train(num_epochs=10)
```

**Use case**: Production training pipeline  
**Best for**: Reproducible ML experiments

### Pattern 2: Transfer Learning with Hugging Face

```python
from transformers import AutoModelForSequenceClassification, AutoTokenizer, Trainer, TrainingArguments
from datasets import load_dataset

# Load pretrained model
model_name = "bert-base-uncased"
model = AutoModelForSequenceClassification.from_pretrained(model_name, num_labels=2)
tokenizer = AutoTokenizer.from_pretrained(model_name)

# Prepare dataset
dataset = load_dataset("imdb")

def tokenize_function(examples):
    return tokenizer(examples["text"], padding="max_length", truncation=True, max_length=512)

tokenized_datasets = dataset.map(tokenize_function, batched=True)

# Training arguments
training_args = TrainingArguments(
    output_dir="./results",
    evaluation_strategy="epoch",
    learning_rate=2e-5,
    per_device_train_batch_size=8,
    per_device_eval_batch_size=8,
    num_train_epochs=3,
    weight_decay=0.01,
    logging_dir="./logs",
    logging_steps=100,
    save_strategy="epoch",
    load_best_model_at_end=True,
    metric_for_best_model="accuracy"
)

# Metrics
from sklearn.metrics import accuracy_score, precision_recall_fscore_support

def compute_metrics(pred):
    labels = pred.label_ids
    preds = pred.predictions.argmax(-1)
    precision, recall, f1, _ = precision_recall_fscore_support(labels, preds, average='binary')
    acc = accuracy_score(labels, preds)
    return {
        'accuracy': acc,
        'f1': f1,
        'precision': precision,
        'recall': recall
    }

# Trainer
trainer = Trainer(
    model=model,
    args=training_args,
    train_dataset=tokenized_datasets["train"].select(range(1000)),  # Subset for demo
    eval_dataset=tokenized_datasets["test"].select(range(200)),
    compute_metrics=compute_metrics
)

# Train
trainer.train()

# Evaluate
results = trainer.evaluate()
print(results)

# Save
trainer.save_model("./fine_tuned_model")
```

**Use case**: NLP transfer learning  
**Best for**: Text classification, NER, QA

### Pattern 3: AutoML with scikit-learn

```python
from sklearn.model_selection import GridSearchCV, RandomizedSearchCV
from sklearn.ensemble import RandomForestClassifier, GradientBoostingClassifier
from sklearn.svm import SVC
from sklearn.pipeline import Pipeline
from sklearn.preprocessing import StandardScaler
import numpy as np

# Define models and parameter grids
models = {
    'rf': (
        RandomForestClassifier(random_state=42),
        {
            'classifier__n_estimators': [50, 100, 200],
            'classifier__max_depth': [None, 10, 20, 30],
            'classifier__min_samples_split': [2, 5, 10]
        }
    ),
    'gb': (
        GradientBoostingClassifier(random_state=42),
        {
            'classifier__n_estimators': [50, 100, 200],
            'classifier__learning_rate': [0.01, 0.1, 0.2],
            'classifier__max_depth': [3, 5, 7]
        }
    ),
    'svm': (
        SVC(random_state=42),
        {
            'classifier__C': [0.1, 1, 10],
            'classifier__kernel': ['rbf', 'linear'],
            'classifier__gamma': ['scale', 'auto']
        }
    )
}

# AutoML function
def auto_ml(X_train, y_train, X_test, y_test):
    results = {}
    
    for name, (model, params) in models.items():
        print(f"\nTraining {name}...")
        
        # Create pipeline
        pipeline = Pipeline([
            ('scaler', StandardScaler()),
            ('classifier', model)
        ])
        
        # Grid search
        grid_search = GridSearchCV(
            pipeline,
            params,
            cv=5,
            scoring='accuracy',
            n_jobs=-1,
            verbose=1
        )
        
        grid_search.fit(X_train, y_train)
        
        # Evaluate
        train_score = grid_search.score(X_train, y_train)
        test_score = grid_search.score(X_test, y_test)
        
        results[name] = {
            'best_params': grid_search.best_params_,
            'train_score': train_score,
            'test_score': test_score,
            'model': grid_search.best_estimator_
        }
        
        print(f"Best params: {grid_search.best_params_}")
        print(f"Train score: {train_score:.4f}")
        print(f"Test score: {test_score:.4f}")
    
    # Find best model
    best_model_name = max(results, key=lambda x: results[x]['test_score'])
    print(f"\nBest model: {best_model_name}")
    
    return results, results[best_model_name]['model']

# Usage
results, best_model = auto_ml(X_train, y_train, X_test, y_test)
```

**Use case**: Automated model selection  
**Best for**: Baseline model comparison

---

## 🔧 Troubleshooting: When the Path is Obscured

### PyTorch Issues

```python
# CUDA out of memory
# Reduce batch size
train_loader = DataLoader(dataset, batch_size=16)  # Instead of 32

# Use gradient accumulation
accumulation_steps = 4
for i, (data, target) in enumerate(train_loader):
    output = model(data)
    loss = criterion(output, target)
    loss = loss / accumulation_steps
    loss.backward()
    
    if (i + 1) % accumulation_steps == 0:
        optimizer.step()
        optimizer.zero_grad()

# Clear cache
torch.cuda.empty_cache()

# Gradient explosion
# Use gradient clipping
torch.nn.utils.clip_grad_norm_(model.parameters(), max_norm=1.0)

# Model not learning
# Check learning rate
print(f"Current LR: {optimizer.param_groups[0]['lr']}")

# Check gradients
for name, param in model.named_parameters():
    if param.grad is not None:
        print(f"{name}: {param.grad.abs().mean()}")
```

### TensorFlow Issues

```python
# GPU memory growth
import tensorflow as tf

gpus = tf.config.list_physical_devices('GPU')
if gpus:
    for gpu in gpus:
        tf.config.experimental.set_memory_growth(gpu, True)

# Mixed precision
from tensorflow.keras import mixed_precision
mixed_precision.set_global_policy('mixed_float16')

# Debugging NaN
tf.debugging.enable_check_numerics()
```

---

## 🙏 Quick Reference

### PyTorch
| Operation | Command |
|-----------|---------|
| Create tensor | `torch.tensor([1, 2, 3])` |
| Move to GPU | `tensor.to('cuda')` |
| Save model | `torch.save(model.state_dict(), 'model.pth')` |
| Load model | `model.load_state_dict(torch.load('model.pth'))` |

### TensorFlow/Keras
| Operation | Command |
|-----------|---------|
| Sequential model | `keras.Sequential([layers...])` |
| Compile | `model.compile(optimizer, loss, metrics)` |
| Train | `model.fit(X, y, epochs=10)` |
| Save | `model.save('model.h5')` |

### scikit-learn
| Operation | Command |
|-----------|---------|
| Train/test split | `train_test_split(X, y, test_size=0.2)` |
| Fit model | `model.fit(X_train, y_train)` |
| Predict | `model.predict(X_test)` |
| Score | `model.score(X_test, y_test)` |

---

*May your gradients flow smoothly, your models converge quickly, and your accuracy always improve.*

**— The Monk of Machine Learning**  
*Temple of Neural Networks*

🧘 **Namaste, `ml`**

---

## 📚 Additional Resources

- [PyTorch Documentation](https://pytorch.org/docs/)
- [TensorFlow Documentation](https://www.tensorflow.org/api_docs)
- [scikit-learn Documentation](https://scikit-learn.org/stable/)
- [Hugging Face Documentation](https://huggingface.co/docs)
- [MLflow Documentation](https://mlflow.org/docs/latest/index.html)
- [Weights & Biases Documentation](https://docs.wandb.ai/)
- [Papers with Code](https://paperswithcode.com/)

---

*Last Updated: 2025-10-02*  
*Version: 1.0.0 - The First Enlightenment*  
*PyTorch: 2.0+ | TensorFlow: 2.13+ | scikit-learn: 1.3+*
