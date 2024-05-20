classdef SpeckleMet_exported < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                matlab.ui.Figure
        CreateHistogramButton   matlab.ui.control.Button
        QualityMetricsLabel     matlab.ui.control.Label
        SpecklePatternQualityCalculatorLabel  matlab.ui.control.Label
        LoadedImageLabel        matlab.ui.control.Label
        ShannonEntropyCheckBox  matlab.ui.control.CheckBox
        MIGCheckBox             matlab.ui.control.CheckBox
        CalculateMetricsButton  matlab.ui.control.Button
        CropButton              matlab.ui.control.Button
        LoadButton              matlab.ui.control.Button
        UIAxes                  matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        Filepath % Store image property here to be accessed when the app is run.

        CroppedImage % If the user creates a cropped image, its property will be stored here. 

        Filename %Store this property for custom naming of histogram images.

    end
    
    methods (Access = private)
        
        function [gradx, grady] = imgradqq(app,A,x,y)

                      
            %This is the imgrad calculator function. Only calculating here
            %using forward difference method. 

            gradx = A(x+1, y) - A(x, y);
            grady = A(x, y+1) - A(x, y); % df(x) = (f(x+dx)-f(x))/dx

        end
    end   

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: LoadButton
        function LoadButtonPushed(app, event)
            
            [file, path] = uigetfile('*.jpg;*.png'); % Opens current path folder.

            app.Filepath = fullfile(path, file); % Write the file path to the property - relevant when using other functions.

            [~,name,~] = fileparts(app.Filepath);
            
            app.Filename = name; %For use in histogram generation section.

            
            if isequal(file, 0)

                disp('Operation cancelled');

            else

                disp(['You selected ', app.Filepath]);

            
            image = imread(app.Filepath);

            % Display the image on the axes when a file is uploaded by the user.

            imshow(image, 'Parent', app.UIAxes); % Display the image without stretching it to fill the axes.

            
            % Fit the image within the axes while retaining the axes'
            % original size.

            axis(app.UIAxes, 'off'); % Turn off the axes' visibility.
            imageSize = size(image);
            imageAspectRatio = imageSize(2) / imageSize(1);
            axesAspectRatio = app.UIAxes.Position(3) / app.UIAxes.Position(4);

            if imageAspectRatio > axesAspectRatio

                % Image is wider, fit width to axes.

                newWidth = app.UIAxes.Position(3);
                newHeight = newWidth / imageAspectRatio;

            else

                % Image is taller, fit height to axes.

                newHeight = app.UIAxes.Position(4);
                newWidth = newHeight * imageAspectRatio;

            end

            % Calculate new position of the axes to center it within its
            % original position.

            newX = app.UIAxes.Position(1) + (app.UIAxes.Position(3) - newWidth) / 2;
            newY = app.UIAxes.Position(2) + (app.UIAxes.Position(4) - newHeight) / 2;
            
            % Set the new position of the axes.

            app.UIAxes.Position = [newX, newY, newWidth, newHeight];

            end

        end

        % Button pushed function: CalculateMetricsButton
        function CalculateMetricsButtonPushed(app, event)
            
            %When this button is pressed, the function runs and the
            %selected metrics are calculated for the chosen speckle
            %pattern.

           if isempty(app.Filepath)

                disp('Please select a file from the current folder to upload.')

           
           else        

                if isempty(app.CroppedImage) %If a cropped image hasn't been created, original file is used.
    
                    im  = imread(app.Filepath); %Reads image from file.
    
                else
                    im = app.CroppedImage;
                end
    
    
                %Box ticking functionality.
    
                if app.MIGCheckBox.Value == 1
    
                [H, W, ~]  = size(im);
                
                %% Convert from RGB to grayscale and to double type.
                imG = rgb2gray(im);
                imGd = double(imG);
    
                %% Calcutating MIG with forward difference.
                mig = 0;
                for x = 1:H-1
                   for y = 1:W-1
                       [gradx, grady] = imgradqq(app,imGd,x,y); %Call in-built app function. 
                       mig = mig + sqrt(gradx^2+grady^2);    
                   end
                end
              
                formatSpec = 'The MIG value of the speckle pattern is %0.5f';
                
                mig1 = mig/((H)*(W));
    
                sprintf(formatSpec,mig1) %Print final statement in command window.
    
               %Displays mig value.
                end
    
                   
               %Next, Shannon entropy calculator function is included.
    
               if app.ShannonEntropyCheckBox.Value == 1
    
                   imG = rgb2gray(im);
    
                   imGd = double(imG); %Convert to double type, stored as a matrix of grey value intensities. 
    
                   [H, W]  = size(imGd);
    
                   entropy_val = 0;
    
                    for index = 0:255 %Scan for probability of each gray level.
    
                        prob_array = find(imGd == index);
                        prob = length(prob_array)/(H*W);
                        log_prob = log2(prob);
    
                       if prob ~= 0 %Prevent giving infinite values for log if there is no value of an intensity present.
    
                        entropy_val = entropy_val + prob*log_prob;    
    
                       end    
    
                   end
    
                entropy_val = -entropy_val;
        
                formatSpec3 = 'The Shannon entropy value of the pattern is %0.5f';
        
                sprintf(formatSpec3,entropy_val) %Display Shannon entropy value in command window. 
        
               end
           end           
           

            
        end

        % Button pushed function: CropButton
        function CropButtonPushed(app, event)
           
            %This function serves to crop the image selected.


            if isempty(app.Filepath) == 1

                disp('Please select a file from the current folder to crop.')

            else


                img = imread(app.Filepath); %Read original image selected from folder
                app.CroppedImage = imcrop(img); %Opens cropping tool

            
            %Cropped image is then displayed on the axes instead of the
            %original image. 

           % Display the image on the axes when a file is uploaded by the user.

            imshow(app.CroppedImage, 'Parent', app.UIAxes); % Display the image without stretching it to fill the axes.

            
            % Fit the image within the axes while retaining the axes'
            % original size.

            axis(app.UIAxes, 'off'); % Turn off the axes' visibility.
            imageSize = size(app.CroppedImage);
            imageAspectRatio = imageSize(2) / imageSize(1);
            axesAspectRatio = app.UIAxes.Position(3) / app.UIAxes.Position(4);

            if imageAspectRatio > axesAspectRatio

                % Image is wider, fit width to axes.

                newWidth = app.UIAxes.Position(3);
                newHeight = newWidth / imageAspectRatio;

            else

                % Image is taller, fit height to axes.

                newHeight = app.UIAxes.Position(4);
                newWidth = newHeight * imageAspectRatio;

            end

            % Calculate new position of the axes to centre it within its
            % original position.

            newX = app.UIAxes.Position(1) + (app.UIAxes.Position(3) - newWidth) / 2;
            newY = app.UIAxes.Position(2) + (app.UIAxes.Position(4) - newHeight) / 2;
            
            % Set the new position of the axes.

            app.UIAxes.Position = [newX, newY, newWidth, newHeight];

            end
        
        end

        % Value changed function: MIGCheckBox
        function MIGCheckBoxValueChanged(app, event)
            value = app.MIGCheckBox.Value; %Run button will run this if box is ticked. 
            
        end

        % Callback function
        function SpeckleSizeCheckBoxValueChanged(app, event)
            value = app.SpeckleSizeCheckBox.Value; %Run button will also run this if box is ticked.
            
        end

        % Value changed function: ShannonEntropyCheckBox
        function ShannonEntropyCheckBoxValueChanged(app, event)
            value = app.ShannonEntropyCheckBox.Value; %Run button will also run this if box is ticked.
            
        end

        % Button pushed function: CreateHistogramButton
        function CreateHistogramButtonPushed(app, event)
            
           if isempty(app.Filepath)

                disp('Please select a file from the current folder to upload.')

           
           else        

                if isempty(app.CroppedImage) %If a cropped image hasn't been created, original file is used.
    
                    im  = imread(app.Filepath); %Reads image from file.
    
                else
                    im = app.CroppedImage;
                end
           
   
            figure

            histogram(im);
            xlabel('Grey intensity value (0-255)','FontSize',15,'Interpreter','latex')
            ylabel('Frequency','FontSize',15,'Interpreter','latex')
            C = sprintf('Frequency of grey values for %s',app.Filename);
            title(C,'FontSize',15,'Interpreter','latex');

            %Save image histogram as a separate file with a custom name. 

            savefig(sprintf('%s_histogram.fig',app.Filename));


           end

        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 640 480];
            app.UIFigure.Name = 'MATLAB App';

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            app.UIAxes.AmbientLightColor = [0 0 0];
            app.UIAxes.XTick = [];
            app.UIAxes.YTick = [];
            app.UIAxes.BoxStyle = 'full';
            colormap(app.UIAxes, 'gray')
            app.UIAxes.Position = [119 207 404 191];

            % Create LoadButton
            app.LoadButton = uibutton(app.UIFigure, 'push');
            app.LoadButton.ButtonPushedFcn = createCallbackFcn(app, @LoadButtonPushed, true);
            app.LoadButton.FontName = 'Gill Sans Nova';
            app.LoadButton.FontSize = 13;
            app.LoadButton.Position = [56 112 123 32];
            app.LoadButton.Text = 'Load';

            % Create CropButton
            app.CropButton = uibutton(app.UIFigure, 'push');
            app.CropButton.ButtonPushedFcn = createCallbackFcn(app, @CropButtonPushed, true);
            app.CropButton.FontName = 'Gill Sans Nova';
            app.CropButton.FontSize = 13;
            app.CropButton.Position = [56 60 123 32];
            app.CropButton.Text = 'Crop';

            % Create CalculateMetricsButton
            app.CalculateMetricsButton = uibutton(app.UIFigure, 'push');
            app.CalculateMetricsButton.ButtonPushedFcn = createCallbackFcn(app, @CalculateMetricsButtonPushed, true);
            app.CalculateMetricsButton.FontName = 'Gill Sans Nova';
            app.CalculateMetricsButton.FontSize = 13;
            app.CalculateMetricsButton.Position = [259 112 123 32];
            app.CalculateMetricsButton.Text = 'Calculate Metrics';

            % Create MIGCheckBox
            app.MIGCheckBox = uicheckbox(app.UIFigure);
            app.MIGCheckBox.ValueChangedFcn = createCallbackFcn(app, @MIGCheckBoxValueChanged, true);
            app.MIGCheckBox.Text = 'MIG';
            app.MIGCheckBox.FontName = 'Gill Sans Nova';
            app.MIGCheckBox.FontSize = 13;
            app.MIGCheckBox.Position = [462 91 59 33];

            % Create ShannonEntropyCheckBox
            app.ShannonEntropyCheckBox = uicheckbox(app.UIFigure);
            app.ShannonEntropyCheckBox.ValueChangedFcn = createCallbackFcn(app, @ShannonEntropyCheckBoxValueChanged, true);
            app.ShannonEntropyCheckBox.Text = 'Shannon Entropy';
            app.ShannonEntropyCheckBox.FontName = 'Gill Sans Nova';
            app.ShannonEntropyCheckBox.FontSize = 13;
            app.ShannonEntropyCheckBox.Position = [462 64 115 28];

            % Create LoadedImageLabel
            app.LoadedImageLabel = uilabel(app.UIFigure);
            app.LoadedImageLabel.FontName = 'Gill Sans Nova';
            app.LoadedImageLabel.FontSize = 13;
            app.LoadedImageLabel.Position = [281 178 79 30];
            app.LoadedImageLabel.Text = 'Loaded Image';

            % Create SpecklePatternQualityCalculatorLabel
            app.SpecklePatternQualityCalculatorLabel = uilabel(app.UIFigure);
            app.SpecklePatternQualityCalculatorLabel.FontName = 'Gill Sans Nova';
            app.SpecklePatternQualityCalculatorLabel.FontSize = 14;
            app.SpecklePatternQualityCalculatorLabel.FontWeight = 'bold';
            app.SpecklePatternQualityCalculatorLabel.Position = [202 397 238 41];
            app.SpecklePatternQualityCalculatorLabel.Text = 'Speckle Pattern Quality Calculator';

            % Create QualityMetricsLabel
            app.QualityMetricsLabel = uilabel(app.UIFigure);
            app.QualityMetricsLabel.FontName = 'Gill Sans Nova';
            app.QualityMetricsLabel.FontSize = 13;
            app.QualityMetricsLabel.FontWeight = 'bold';
            app.QualityMetricsLabel.FontAngle = 'italic';
            app.QualityMetricsLabel.Position = [462 131 140 25];
            app.QualityMetricsLabel.Text = 'Quality Metrics';

            % Create CreateHistogramButton
            app.CreateHistogramButton = uibutton(app.UIFigure, 'push');
            app.CreateHistogramButton.ButtonPushedFcn = createCallbackFcn(app, @CreateHistogramButtonPushed, true);
            app.CreateHistogramButton.FontName = 'Gill Sans Nova';
            app.CreateHistogramButton.Position = [259 60 123 32];
            app.CreateHistogramButton.Text = 'Create Histogram';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = SpeckleSense_exported

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
