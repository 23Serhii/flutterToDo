const express = require("express");
const mongoose = require("mongoose");

const app = express();
const port = 3000;

// Connect to MongoDB
mongoose
  .connect(
    "mongodb+srv://uantredogbusiness:CAllisto821@cluster0.i3ba12c.mongodb.net/",
    { useNewUrlParser: true, useUnifiedTopology: true }
  )
  .then(() => {
    console.log("Connected to MongoDB");
  })
  .catch((error) => {
    console.error("Failed to connect to MongoDB", error);
  });
  echo "# flutterToDo" >> README.md
// Define task schema
const taskSchema = new mongoose.Schema({
  status: Number,
  name: String,
  type: Number,
  description: String,
  finishDate: String,
  urgent: Number,
  file: String,
});

const Task = mongoose.model("Task", taskSchema);

// Get all tasks
app.get("/tasks", (req, res) => {
  Task.find()
    .then((tasks) => {
      res.json({
        error: null,
        data: tasks,
      });
    })
    .catch((error) => {
      res.json({
        error: "Failed to fetch tasks",
        data: [],
      });
    });
});

// Create a new task
app.post("/tasks", (req, res) => {
  const newTask = new Task(req.body);
  newTask
    .save()
    .then(() => {
      res.json({
        error: null,
        data: newTask,
      });
    })
    .catch((error) => {
      res.json({
        error: "Failed to create task",
        data: null,
      });
    });
});

// Update task status
app.put("/tasks/:taskId", (req, res) => {
  const { taskId } = req.params;
  const { status } = req.body;
  Task.findByIdAndUpdate(taskId, { status })
    .then(() => {
      res.json({
        error: null,
        data: null,
      });
    })
    .catch((error) => {
      res.json({
        error: "Failed to update task status",
        data: null,
      });
    });
});

// Delete a task
app.delete("/tasks/:taskId", (req, res) => {
  const { taskId } = req.params;
  Task.findByIdAndDelete(taskId)
    .then(() => {
      res.json({
        error: null,
        data: null,
      });
    })
    .catch((error) => {
      res.json({
        error: "Failed to delete task",
        data: null,
      });
    });
});

app.listen(port, () => {
  console.log(`Server is running on port ${port}`);
});
