package controllers;

import database.Database;
import database.Driver;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.TableView;
import javafx.stage.Stage;

import java.io.IOException;

public class FirmsController {
    // TODO: add fields
    @FXML
    private TableView<?> tableView;
    @FXML
    private Button addButton;

    @FXML
    public void addFirm(final ActionEvent event) {
        // TODO: adding firm to database
    }

    @FXML
    public void initialize() {
        //TODO: fill tableview
    }
}
