package com.example.ftechdm3;

import static com.example.ftechdm3.R.string.build_number;

import java.util.Locale;
import android.Manifest;
import android.annotation.SuppressLint;
import android.content.Context;
import android.content.pm.PackageManager;
import android.location.Location;
import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.widget.Button;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;

import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.TimeZone;

public class MainActivity extends AppCompatActivity implements LocationListener {

    private TextView buildTextView;
    private LocationManager locationManager;
    private DatabaseReference databaseReference;
    private String androidId;

    @SuppressLint("HardwareIds")
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        buildTextView = findViewById(R.id.build_text_view);

        Button sosButton = findViewById(R.id.emergency_sos_button);

        FirebaseDatabase database = FirebaseDatabase.getInstance();
        databaseReference = database.getReference("users");

        androidId = Settings.Secure.getString(getContentResolver(), Settings.Secure.ANDROID_ID);

        locationManager = (LocationManager) getSystemService(Context.LOCATION_SERVICE);

        sosButton.setOnClickListener(view -> {
            if (ActivityCompat.checkSelfPermission(MainActivity.this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
                    && ActivityCompat.checkSelfPermission(MainActivity.this, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
                locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 0, 0, MainActivity.this);
            } else {
                ActivityCompat.requestPermissions(MainActivity.this, new String[]{Manifest.permission.ACCESS_FINE_LOCATION, Manifest.permission.ACCESS_COARSE_LOCATION}, 1);
            }
        });

        if (ActivityCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) != PackageManager.PERMISSION_GRANTED) {
            ActivityCompat.requestPermissions(this, new String[]{Manifest.permission.READ_PHONE_STATE}, 2);
        } else {
            displayBuildNumber();
        }
    }

    @SuppressLint("HardwareIds")
    @Override
    public void onLocationChanged(@NonNull Location location) {
        double latitude = location.getLatitude();
        double longitude = location.getLongitude();

        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault());
        sdf.setTimeZone(TimeZone.getTimeZone("Asia/Kolkata"));
        String timestamp = sdf.format(new Date());

        DatabaseReference userReference = databaseReference.child(androidId);
        userReference.child("latitude").setValue(latitude);
        userReference.child("longitude").setValue(longitude);
        userReference.child("timestamp").setValue(timestamp);

        Toast.makeText(this, "Location updated", Toast.LENGTH_SHORT).show();

        locationManager.removeUpdates(this);
    }

    @Override
    public void onStatusChanged(String provider, int status, Bundle extras) {}

    @Override
    public void onProviderEnabled(@NonNull String provider) {}

    @Override
    public void onProviderDisabled(@NonNull String provider) {
        Toast.makeText(this, "Please enable GPS and Internet", Toast.LENGTH_SHORT).show();
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        if (requestCode == 1) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                if (ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_FINE_LOCATION) == PackageManager.PERMISSION_GRANTED
                        && ActivityCompat.checkSelfPermission(this, Manifest.permission.ACCESS_COARSE_LOCATION) == PackageManager.PERMISSION_GRANTED) {
                    locationManager.requestLocationUpdates(LocationManager.GPS_PROVIDER, 0, 0, this);
                }
            }
        } else if (requestCode == 2) {
            if (grantResults.length > 0 && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                displayBuildNumber();
            }
        }
    }

    @SuppressLint("MissingPermission")
    private void displayBuildNumber() {
        String buildNumber = Build.DISPLAY;
        buildTextView.setText(getString(build_number, buildNumber));
        DatabaseReference userReference = databaseReference.child(androidId);
        userReference.child("buildNumber").setValue(buildNumber);
    }
}
