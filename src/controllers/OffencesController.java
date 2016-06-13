package controllers;

import database.Database;
import database.Offence;
import javafx.event.ActionEvent;
import javafx.fxml.FXML;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.scene.control.Button;
import javafx.scene.control.TableView;
import javafx.stage.Stage;

import java.io.IOException;

public class OffencesController {
    @FXML
    private TableView<?> tableView;
    @FXML
    private Button rankingButton;

    @FXML
    public void initialize() {
        Database.instance.getOffenceTable((TableView<Offence>) tableView);
    }

    @FXML
    public void showRanking(final ActionEvent event) {
        try {
            final Parent root = FXMLLoader.load(getClass().getResource("../FXML/dangerousDriversWindow.fxml"));
            final Stage stage = new Stage();
            stage.setTitle("Ranking niebezpiecznych kierowców");
            stage.setScene(new Scene(root, 510, 480));
            stage.show();

        } catch (final IOException e) {
            e.printStackTrace();
        }
    }

}
