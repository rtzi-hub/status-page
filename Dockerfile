# Step 1: Using Python
FROM python:3.10-slim

# Step 2: Set environment variables to avoid Python buffering issues
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Step 3: Set the working directory inside the container
WORKDIR /app

# Step 4: Copy the application files into the container
COPY . /app/

# Step 5: Install system packages needed for PostgreSQL and other dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Step 6: Ensure the upgrade.sh script is executable
RUN chmod +x /app/upgrade.sh

# Step 7: Install Python dependencies (without running the upgrade.sh now)
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Step 8: Expose the port where Django will run
EXPOSE 8000

# Step 9: Create an entrypoint to run the upgrade.sh at runtime and start Gunicorn
ENTRYPOINT ["./upgrade.sh"]

# Step 10: Start the Gunicorn server to serve the Django application after running upgrade.sh
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "statuspage.wsgi:application"]
