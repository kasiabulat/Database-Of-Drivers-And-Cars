import javafx.application.Application;
import javafx.fxml.FXMLLoader;
import javafx.scene.Parent;
import javafx.scene.Scene;
import javafx.stage.Stage;

public class Main extends Application {

    @Override
    public void start(Stage primaryStage) throws Exception{
        Parent root = FXMLLoader.load(getClass().getResource("FXML/mainWindow.fxml"));
        primaryStage.setTitle("System ewidencji pojazdów i kierowców");
        primaryStage.setScene(new Scene(root, 300, 220));
        primaryStage.show();
    }


    public static void main(String[] args) {
        launch(args);
    }
}
