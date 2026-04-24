classdef schlieren_app < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        TabGroup                        matlab.ui.container.TabGroup
        ImagepreprocessingTab           matlab.ui.container.Tab
        Image                           matlab.ui.control.Image
        Numberofreplicate               matlab.ui.control.NumericEditField
        NumberofreplicateEditFieldLabel  matlab.ui.control.Label
        tab1_path_display               matlab.ui.control.EditField
        RunButton                       matlab.ui.control.Button
        SelectafolderButton             matlab.ui.control.Button
        Name2                           matlab.ui.control.EditField
        Name2EditFieldLabel             matlab.ui.control.Label
        Bufferpartcount                 matlab.ui.control.NumericEditField
        BufferpartcountEditFieldLabel   matlab.ui.control.Label
        Name1                           matlab.ui.control.EditField
        Name1EditFieldLabel             matlab.ui.control.Label
        Number_of_raw_image             matlab.ui.control.NumericEditField
        NumberofrawimagesLabel          matlab.ui.control.Label
        OpticalflowanalysisquivermapTab  matlab.ui.container.Tab
        Image2                          matlab.ui.control.Image
        processingstatus                matlab.ui.control.EditField
        ProcessingstatusLabel           matlab.ui.control.Label
        RunButton_2                     matlab.ui.control.Button
        Framerate_of_raw_video          matlab.ui.control.NumericEditField
        RawvideoframerateLabel          matlab.ui.control.Label
        NumberofframeforanalysisEditField  matlab.ui.control.NumericEditField
        NumberofframeforanalysisEditFieldLabel  matlab.ui.control.Label
        First_frame_to_analyze          matlab.ui.control.NumericEditField
        FirstframeforanalysisLabel      matlab.ui.control.Label
        OFfolderpath                    matlab.ui.control.EditField
        OFfolderbutton                  matlab.ui.control.Button
        OpticalflowanalysisheatmapTab   matlab.ui.container.Tab
        Meanvelocitycms_colormap        matlab.ui.control.NumericEditField
        MeanvelocitycmsEditFieldLabel   matlab.ui.control.Label
        Image2_2                        matlab.ui.control.Image
        Numberofframetoanalyze_colormap  matlab.ui.control.NumericEditField
        NumberofframeforanalysisLabel   matlab.ui.control.Label
        Rawvideofarmerate_colormap      matlab.ui.control.NumericEditField
        RawvideofarmerateEditFieldLabel  matlab.ui.control.Label
        Firstframetoanalyze_colormap    matlab.ui.control.NumericEditField
        FirstframeforanalysisLabel_2    matlab.ui.control.Label
        filenameEditField               matlab.ui.control.EditField
        filenameEditFieldLabel          matlab.ui.control.Label
        colorpath                       matlab.ui.control.EditField
        SelectavideoButton              matlab.ui.control.Button
        RunButton_3                     matlab.ui.control.Button
        FlowpatterncharacterizationTab  matlab.ui.container.Tab
        Timeratioofturbulentflow_flow   matlab.ui.control.NumericEditField
        TimeratioofturbulentflowEditFieldLabel  matlab.ui.control.Label
        RunButton_4                     matlab.ui.control.Button
        Numberofframetoanalyze_flow     matlab.ui.control.NumericEditField
        NumberofframeforanalysisLabel_2  matlab.ui.control.Label
        Firstframetoanalyze_flow        matlab.ui.control.NumericEditField
        FirstframeforanalysisLabel_3    matlab.ui.control.Label
        filename_flow                   matlab.ui.control.EditField
        filenameEditFieldLabel_flow     matlab.ui.control.Label
        path_flow                       matlab.ui.control.EditField
        SelectavideoButton_flow         matlab.ui.control.Button
        Image2_3                        matlab.ui.control.Image
    end

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: SelectafolderButton
        function SelectafolderButtonPushed(app, event)
            % To select a parent folder, where the 10 sub-folders named R0, R1, ..., to R9 are inside this parent folder.
            tab1_path = uigetdir;
            app.tab1_path_display.Value = tab1_path;
        end

        % Button pushed function: RunButton
        function RunButtonPushed(app, event)
        % Import parameters from user interface & set default parameters
        resolution_width = 1280;
        resolution_height = 800;
        bufferpartcount = app.Bufferpartcount.Value ;
        name1 = app.Name1.Value;
        name2 = app.Name2.Value;
        num_of_raw_img = app.Number_of_raw_image.Value;
        num_of_replicate = app.Numberofreplicate.Value;
        tab1_path = app.tab1_path_display.Value;

        % Image cropping    
        for counter_replicate = 0: (num_of_replicate-1)
            folder = strcat('\R',num2str(counter_replicate),'\');
             for counter = 0 : (num_of_raw_img -1) 
                  prepended_counter =  num2str(counter,'%03.f'); 
                  file = strcat ( 'img.',prepended_counter,'.bmp'); 
                  read_img = imread ( strcat(tab1_path,folder,file) );
                  
                 for counter_2 = 1 : bufferpartcount
                     cropped_img = read_img ((1 + (resolution_height*(counter_2-1))) : (resolution_height + (resolution_height*(counter_2-1))), 1 : resolution_width);
                     imwrite (cropped_img, strcat (tab1_path,folder,'\a',string(counter_2 + bufferpartcount*counter),'.jpg'));
                 end
    
             end

            % Writing the video
             VW = VideoWriter(strcat(tab1_path,'\',name1,num2str(counter_replicate),'.',name2),'Motion JPEG AVI');
             VW.Quality = 80;
             VW.FrameRate = 3 ;
             open (VW);
             frame_2 = 1 ;
             num_of_frame = (counter+1) * bufferpartcount;
                for counter_3 = frame_2 : (frame_2+num_of_frame-1)
                    img_for_video_name = strcat('a',string(counter_3),'.jpg');
                    img_for_video = imread (strcat(tab1_path,folder,'\',img_for_video_name));
                    writeVideo (VW,img_for_video);
                end
            close(VW);
        end
        end

        % Button pushed function: OFfolderbutton
        function OFfolderbuttonButtonPushed(app, event)
        of_path = uigetdir;
        app.OFfolderpath.Value = of_path;
        filename = dir (of_path);
        namelist = {filename.name};
        [namelist_m namelist_n] = size(namelist);
        app.processingstatus.Value = strcat( num2str(0), '/', num2str(namelist_n-2));

        end

        % Button pushed function: RunButton_2
        function RunButton_2Pushed(app, event)
        % Setting parameters of opticflow method
        opticFlow = opticalFlowFarneback;
        opticFLow.PyramidScale = 0.5;
        opticFLow.NumIterations = 3;
        opticFLow.NeighborhoodSize = 5;
        opticFLow.FilterSize =15;
        opticFlow.NumPyramidLevels =3;
        enhancement_low_thres = 0.1 ;
        enhancement_high_thres = 0.5 ;

        % Import parameters from user interface
        raw_framerate = app.Framerate_of_raw_video.Value;
        num_of_frame_to_analyze = app.NumberofframeforanalysisEditField.Value;
        first_frame_of_analyzing = app.First_frame_to_analyze.Value;
        of_path = app.OFfolderpath.Value;
        filename = dir (of_path);
        namelist = {filename.name};
        [namelist_m namelist_n] = size(namelist);

        % Preallocating the data matrix
        avg_total_mean = zeros (namelist_n,1);
        avg_Std = zeros (namelist_n,1);
        avg_sampling_data = zeros (namelist_n,1);
            for namelist_counter = 3 : namelist_n
              app.processingstatus.Value = strcat( num2str(namelist_counter-2), '/', num2str(namelist_n-2));
              VR = VideoReader ( strcat ( of_path,'\',namelist{namelist_counter}));
              VW_name  = strcat ( VR.name, '_opticflow');
              VW = VideoWriter (strcat(of_path,VW_name));
              VW.FrameRate = 3; 
              open(VW);                              
              % Interative circle drawing
              if namelist_counter == 3 %only run in the first iteration
                 Reference_gray_IM = rgb2gray(read(VR,1));
                 Ref_IM_enhanced = imadjust(Reference_gray_IM, [enhancement_low_thres enhancement_high_thres]);
                 bottom_thres_ref_image_intensity = max(Ref_IM_enhanced,[],'all')*0.1;
                 considered_ref_image_intensity = Ref_IM_enhanced(Ref_IM_enhanced > bottom_thres_ref_image_intensity);
                 average_ref_image_intensity  =mean( considered_ref_image_intensity);
                 name0 = strcat('Average image intensity = ',num2str(average_ref_image_intensity,'%.0f'), '  / 255');
                 imshow(Ref_IM_enhanced);
                 IM_ref = gcf;
                 IM_ref.MenuBar = 'none';
                 IM_ref.ToolBar = 'none';
                 IM_ref.WindowState = 'fullscreen';
                 hold on
                 ref_image_intensity_text = text(20,60, name0);  
                 ref_image_intensity_text.Color = 'red';
                 ref_image_intensity_text.FontSize = 14;
                 ref_image_intensity_text.FontWeight = 'bold' ;
                 hold off
                 circle_stat = drawcircle;
                 wait (circle_stat); 
                 cm_to_pixel = 5.08 / circle_stat.Radius ; 
                 speed =  cm_to_pixel * raw_framerate ;
             end
             % Preallocating the data matrix
             std_array = zeros ((first_frame_of_analyzing + num_of_frame_to_analyze),1);
             sampled_data_array = zeros ((first_frame_of_analyzing + num_of_frame_to_analyze),1);
             intensity_avg_array = zeros ((first_frame_of_analyzing + num_of_frame_to_analyze),1);

             % Creating loop for image processing and optical flow algorithm
             for frame = first_frame_of_analyzing :  first_frame_of_analyzing+num_of_frame_to_analyze-1;
             raw_image(:,:,:)=read(VR,frame);
             imshow(raw_image);
             raw_image_big = gcf;
             raw_image_big.MenuBar = 'none';
             raw_image_big.ToolBar = 'none';
             raw_image_big.WindowState = 'fullscreen';
             raw_image_big_rgb =  getframe(raw_image_big);
             raw_image_big_gray = rgb2gray(raw_image_big_rgb.cdata);
             IM_enhanced = imadjust(raw_image_big_gray , [enhancement_low_thres enhancement_high_thres]);   
             IM_optical = estimateFlow (opticFlow,IM_enhanced);
             mag = IM_optical.Magnitude;
             bottom_threshold = max(mag,[],'all')*0.7; 
  
             % Statistical calculation for optical flow 
             % Filtering
             intensity_for_opticalflow_plot  = mag ;
             intensity_for_opticalflow_plot ( intensity_for_opticalflow_plot < bottom_threshold ) = 0; 
             intensity_for_opticalflow_plot_filtered = intensity_for_opticalflow_plot ( intensity_for_opticalflow_plot >= 1) - 1;
    
             % Display statistics on each frame
             sampled_number = size(intensity_for_opticalflow_plot_filtered);
             std_array (frame, 1) = std (intensity_for_opticalflow_plot_filtered);
             sampled_data_array(frame,1) = sampled_number(1,1);
             intensity_avg_array(frame,1) =  mean(intensity_for_opticalflow_plot_filtered* speed) ;
             avg_speed = sprintf ( '%.2f',  intensity_avg_array(frame,1));
             std_array_str = sprintf ( '%.2f', std_array (frame,1));
             sampled_data_str =  sprintf ( '%.0f', sampled_data_array(frame,1) );
             name = strcat('Average speed = ',avg_speed, ' cm / s');
             name2 = strcat('Standard deviation = ',std_array_str, ' cm ');
             name3 = strcat('Sampled data points =  ', sampled_data_str);
             name_all = {name, name2,name3};
             imshow(raw_image_big_gray);
             hold on
             plot(IM_optical,'DecimationFactor',[30 30],'ScaleFactor',3)
             plot_quiver = findobj(gca,'type','Quiver');
             plot_quiver.Color = 'r';
             plot_quiver.LineWidth = 2;
             axis off
             plot_text = text(200,200,name_all);
             plot_text.Color = 'red';
             plot_text.FontSize = 14;
             plot_text.FontWeight = 'bold' ;
             hold off
             fig_opticflow = gcf;
             fig_opticflow.MenuBar = 'none';
             fig_opticflow.ToolBar = 'none';
             fig_opticflow.WindowState = 'fullscreen';
             Frame_opticflow = getframe(fig_opticflow);
             drawnow;
             writeVideo(VW,Frame_opticflow.cdata);    
          end

             % Statistic calculation for overall vapor velocity 
             avg_total = intensity_avg_array(first_frame_of_analyzing +1 : (first_frame_of_analyzing  + num_of_frame_to_analyze-1 ),1); 
             five_bottom_thre_avg_total = maxk(avg_total,5); 
             bottom_thre_avg_total =  mean(five_bottom_thre_avg_total)*0.2;
             avg_total = avg_total( avg_total  >= bottom_thre_avg_total);
             avg_total_mean (namelist_counter,1) = mean (avg_total);
             avg_Std (namelist_counter,1) = mean(std_array(first_frame_of_analyzing +1 : (first_frame_of_analyzing  + num_of_frame_to_analyze-1 ),1));
             avg_sampling_data (namelist_counter,1) = mean (sampled_data_array(first_frame_of_analyzing +1 : (first_frame_of_analyzing  + num_of_frame_to_analyze-1 ),1));
             close(VW);

            end
             % Output the analysis result
             analysis_result = struct ('Name', namelist', 'Mean_vapor_velocity', num2cell(avg_total_mean), 'Mean_std', num2cell(avg_Std), 'Mean_sampled_datapoint', num2cell(avg_sampling_data));
             writetable(struct2table(analysis_result), strcat ( of_path,'\','analysis_result.xlsx'));

        end

        % Button pushed function: RunButton_3
        function RunButton_3Pushed(app, event)

        % Setting parameters of opticflow method
        opticFlow = opticalFlowFarneback;
        opticFLow.PyramidScale = 0.5;
        opticFLow.NumIterations = 3;
        opticFLow.NeighborhoodSize = 5;
        opticFLow.FilterSize =15;
        opticFlow.NumPyramidLevels =3 ;
        
        % Import the video file from user interface
        color_path = app.colorpath.Value;
        file = app.filenameEditField.Value;
        VR=VideoReader(strcat(color_path,file));
        VW_name  = strcat(file, '_heatmap');

        % Setting video frame range and framerate
        VW = VideoWriter(strcat(color_path,VW_name));
        VW.FrameRate = 3; 
        first_frame_of_analyzing = app.Firstframetoanalyze_colormap.Value;                                            
        num_of_frame_to_analyze = app.Numberofframetoanalyze_colormap.Value;        
        enhancement_low_thres = 0.1 ;
        enhancement_high_thres = 0.5 ;
        raw_framerate = app.Rawvideofarmerate_colormap.Value;
        open(VW);                              

        % Interative circle drawing
        Reference_gray_IM = rgb2gray ( read(VR,1) );
        Ref_IM_enhanced = imadjust(Reference_gray_IM, [enhancement_low_thres enhancement_high_thres]);
        bottom_thres_ref_image_intensity = max(Ref_IM_enhanced,[],'all')*0.1;
        considered_ref_image_intensity = Ref_IM_enhanced(Ref_IM_enhanced > bottom_thres_ref_image_intensity);
        average_ref_image_intensity  =mean( considered_ref_image_intensity );
        name0 = strcat('Average image intensity = ',num2str(average_ref_image_intensity,'%.0f'), '  / 255');
        imshow(Ref_IM_enhanced);
        IM_ref = gcf;
        IM_ref.MenuBar = 'none';
        IM_ref.ToolBar = 'none';
        IM_ref.WindowState = 'fullscreen';
        hold on
        ref_image_intensity_text = text(20,60, name0);  
        ref_image_intensity_text.Color = 'red';
        ref_image_intensity_text.FontSize = 14;
        ref_image_intensity_text.FontWeight = 'bold' ;
        hold off
        circle_stat = drawcircle;
        wait (circle_stat); 
        cm_to_pixel = 5.08 / circle_stat.Radius ; 
        speed =  cm_to_pixel * raw_framerate ;
        
        % Creating loop for image processing and optical flow algorithm
        for frame = first_frame_of_analyzing : first_frame_of_analyzing+num_of_frame_to_analyze-1
            raw_image(:,:,:)=read(VR,frame);
            imshow(raw_image);
            raw_image_big = gcf;
            raw_image_big.MenuBar = 'none';
            raw_image_big.ToolBar = 'none';
            raw_image_big.WindowState = 'fullscreen';
            raw_image_big_rgb =  getframe(raw_image_big);
            raw_image_big_gray = rgb2gray(raw_image_big_rgb.cdata);
            IM_enhanced = imadjust(raw_image_big_gray , [enhancement_low_thres enhancement_high_thres]);   
            IM_optical = estimateFlow (opticFlow,IM_enhanced);
            mag = IM_optical.Magnitude;
            bottom_threshold = max(mag,[],'all')*0.7;
  
            % Statistical calculation of optical flow 
            % Filtering
            intensity_for_heatmap = mag;
            intensity_for_statistics = mag;
            intensity_for_statistics  ( intensity_for_statistics < bottom_threshold ) = 0 ;
            intensity_for_statistics_filtered = intensity_for_statistics ( intensity_for_statistics >= 1) - 1;
            Mag_data(:,:,frame) = intensity_for_statistics;
    
            % Display data on each frame
            sampled_number = size ( intensity_for_statistics_filtered );
            std_array (frame, 1) = std (intensity_for_statistics_filtered);
            sampled_data (frame,1) = sampled_number(1,1);
            intensity_avg(frame,1) = ( (mean(intensity_for_statistics_filtered(:,1))) * speed );
      

            % Creating heatmap
            mag_heatmap = heatmap(intensity_for_heatmap,'Colormap',turbo,'GridVisible','off','xlabel',"  ",'ylabel'," " , 'ColorLimits', [2  20],'MissingDataColor',[0 0 0] );
            Ax = gca;
            Ax.XDisplayLabels = nan(size(Ax.XDisplayData));
            Ax.YDisplayLabels = nan(size(Ax.YDisplayData));
            colorbar('off')
            heatmap_gcf = gcf;
            heatmap_gcf.MenuBar = 'none';
            heatmap_gcf.ToolBar = 'none';
            heatmap_gcf.WindowState = 'fullscreen';
            Heatmapimage = getframe(heatmap_gcf);
            transparency_array = zeros(1080,1920) + 0.3; 
            transparency_array ( Heatmapimage.cdata(:,:,1) == 0 & Heatmapimage.cdata(:,:,2) == 0 & Heatmapimage.cdata(:,:,3) ==0 ) = 0;
            
            % Overlay two images
            imshow(raw_image_big_gray);
            overlay_image_big = gcf;
            overlay_image_big.MenuBar = 'none';
            overlay_image_big.ToolBar = 'none';
            overlay_image_big.WindowState = 'fullscreen';
            hold on
            image(Heatmapimage.cdata, 'AlphaData', transparency_array);
            hold off
            drawnow;
            Overlayed_image = getframe(overlay_image_big);
            if frame == first_frame_of_analyzing
                continue
            end
            writeVideo(VW,Overlayed_image.cdata);
        end

        % Statistic calculation for mean vapor velocity
        avg_total = intensity_avg(first_frame_of_analyzing +1 : (first_frame_of_analyzing  + num_of_frame_to_analyze-1 ),1); 
        five_bottom_thre_avg_total = maxk(avg_total,5); 
        bottom_thre_avg_total =  mean(five_bottom_thre_avg_total)*0.2; 
        avg_total = avg_total ( avg_total  >= bottom_thre_avg_total);
        avg_total_mean = mean (avg_total);
        avg_Std = mean( std_array(first_frame_of_analyzing +1 : (first_frame_of_analyzing  + num_of_frame_to_analyze-1 ),1) );
        avg_sampling_data = mean (sampled_data (first_frame_of_analyzing +1 : (first_frame_of_analyzing  + num_of_frame_to_analyze - 1),1) );
        disp ([' Mean velocity of ', file, ' is ' num2str(avg_total_mean), ' cm / s' ] );
        disp ([' standard deviation of ', file, ' is ' num2str(avg_Std), ' cm ' ] );
        disp ([' Mean sampled data point ' , file, ' is ' num2str(avg_sampling_data) ] );
        close(VW);
        extract_mag = Mag_data (:,:, 1+ first_frame_of_analyzing : first_frame_of_analyzing + num_of_frame_to_analyze -1);
        avg_mag = mean (extract_mag,3);
        intensity_for_avg_heatmap = avg_mag;
        mag_heatmap = heatmap(intensity_for_avg_heatmap,'Colormap',turbo,'GridVisible','off','xlabel',"  ",'ylabel'," " ,'Colorlimit',[0 1.5],'MissingDataColor',[0 0 0] );
        Ax = gca;
        Ax.XDisplayLabels = nan(size(Ax.XDisplayData));
        Ax.YDisplayLabels = nan(size(Ax.YDisplayData));
        colorbar('off')
        heatmap_gcf = gcf;
        heatmap_gcf.MenuBar = 'none';
        heatmap_gcf.ToolBar = 'none';
        heatmap_gcf.WindowState = 'fullscreen';
        Heatmapimage = getframe(heatmap_gcf);
   
        % Overlay two images
        imshow( raw_image_big_gray );
        overlay_image_big = gcf;
        overlay_image_big.MenuBar = 'none';
        overlay_image_big.ToolBar = 'none';
        overlay_image_big.WindowState = 'fullscreen';
        hold on
        image(Heatmapimage.cdata, 'AlphaData', transparency_array);
        hold off
        drawnow;
        Overlayed_image = getframe(overlay_image_big);
        imwrite(Overlayed_image.cdata, strcat(color_path,"averaged heatmap.jpg"));
        app.Meanvelocitycms_colormap.Value = double(avg_total_mean);
        end

        % Button pushed function: SelectavideoButton
        function SelectavideoButtonPushed(app, event)
        [file,color_path] = uigetfile({'*.MOV;*.avi;*.mp4'});
        app.colorpath.Value = color_path;
        app.filenameEditField.Value = file;
        end

        % Button pushed function: RunButton_4
        function RunButton_4Pushed(app, event)
        % Import parameters from user interface & video setting
        flow_path = app.path_flow.Value;
        flow_file = app.filename_flow.Value;
        VR=VideoReader(strcat(flow_path,flow_file));
        VW_name  = strcat(flow_file, '_character');
        Video_for_flow_pattern = VideoWriter(strcat(flow_path,VW_name));
        first_frame_of_analyzing = app.Firstframetoanalyze_flow.Value ;                                                  
        num_of_frame_to_analyze = app.Numberofframetoanalyze_flow.Value;
        Video_for_flow_pattern.FrameRate = 1; 
        color_frame = 1;
        open(Video_for_flow_pattern);
        
        % Interactive square drawing
        Reference_img_for_drawing = read(VR,1);
        Reference_img_for_drawing_en = imadjust (Reference_img_for_drawing, [0.1 0.4]);
        imshow(Reference_img_for_drawing_en);
        IM_ref = gcf;
        IM_ref.MenuBar = 'none';
        IM_ref.ToolBar = 'none';
        IM_ref.WindowState = 'fullscreen';
        rect_draw= drawrectangle;
        wait(rect_draw);
        rect_position = round(rect_draw.Position); 

        for color_frame = first_frame_of_analyzing :  first_frame_of_analyzing+num_of_frame_to_analyze-1
            raw_image(:,:,:)=read(VR,color_frame);
            gray_image = rgb2gray(raw_image);
            enhanced_gray_image = imadjust (gray_image, [0.1 0.4]);
            Extracted_rect_inten  = enhanced_gray_image (rect_position(1,2) : (rect_position(1,2) + rect_position(1,4)-1), rect_position(1,1) : (rect_position(1,1) + rect_position(1,3)-1));
            Std (color_frame,:) = std(double(Extracted_rect_inten)); 
        end
    

        % Characterization of flow pattern
        mean_std = mean(Std,2);
        Filtered_mean_std = sgolayfilt(mean_std, 3, 11);
        frame_array = 1:size(mean_std);
        laminar_turbulent_logical_array = (mean_std - Filtered_mean_std) > 2;

        % Writing video 
        color_frame = 1;
        for color_frame = first_frame_of_analyzing :  first_frame_of_analyzing+num_of_frame_to_analyze-1
            raw_image(:,:,:)=read(VR,color_frame);
            gray_image = rgb2gray(raw_image);
            enhanced_gray_image = imadjust( gray_image, [0.1 0.4]);
            imshow(enhanced_gray_image);
            gray_image_big = gcf;
            gray_image_big.MenuBar = 'none';
            gray_image_big.ToolBar = 'none';
            gray_image_big.WindowState = 'fullscreen';
            rectangle('Position',rect_position,'EdgeColor',"r",'LineWidth',0.75); 
            name_4 = strcat ("Mean standard deviation is ", sprintf ( '%.2f', mean_std(color_frame,1) ));
            name_5 = {name_4, 'Flow pattern is laminar'};
            name_6 = {name_4, 'Flow pattern is turbulent'};
   
        if mean_std(color_frame,1)*laminar_turbulent_logical_array(color_frame,1) == 0
           t_2 = text (120, 120, name_5);
           t_2.Color = 'red';
           t_2.FontSize = 14;
           t_2.FontWeight = 'bold';
        
        else
           t_2 = text ( 120, 120, name_6);
           t_2.Color = 'red';
           t_2.FontSize = 14;
           t_2.FontWeight = 'bold';
       
        end
        
        drawnow;
        F = getframe(gray_image_big);
        writeVideo(Video_for_flow_pattern,F.cdata);
        end
        close(Video_for_flow_pattern);
       
        % Time ratio of turbulent flow
        Num_of_turbulent = size(find(laminar_turbulent_logical_array == 1),1);
        app.Timeratioofturbulentflow_flow.Value = Num_of_turbulent / size(mean_std,1);
        plot (frame_array ,mean_std, frame_array(laminar_turbulent_logical_array), mean_std(laminar_turbulent_logical_array),'r*');
        p = gcf;
        exportgraphics(p,strcat(flow_path,'plot.png'),'Resolution',300);
        sub_array = mean_std - Filtered_mean_std;
        plot (frame_array ,sub_array, frame_array(laminar_turbulent_logical_array), sub_array(laminar_turbulent_logical_array),'r*');
        p = gcf;
        exportgraphics(p,strcat(flow_path,'subplot.png'),'Resolution',300);
        end

        % Button pushed function: SelectavideoButton_flow
        function SelectavideoButton_flowPushed(app, event)
        [flow_file,flow_path] = uigetfile({'*.MOV;*.avi;*.mp4'});
        app.path_flow.Value = flow_path;
        app.filename_flow.Value = flow_file;
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 446 211];
            app.UIFigure.Name = 'MATLAB App';

            % Create TabGroup
            app.TabGroup = uitabgroup(app.UIFigure);
            app.TabGroup.Position = [1 0 446 212];

            % Create ImagepreprocessingTab
            app.ImagepreprocessingTab = uitab(app.TabGroup);
            app.ImagepreprocessingTab.Title = 'Image preprocessing';

            % Create NumberofrawimagesLabel
            app.NumberofrawimagesLabel = uilabel(app.ImagepreprocessingTab);
            app.NumberofrawimagesLabel.HorizontalAlignment = 'right';
            app.NumberofrawimagesLabel.Position = [175 141 126 22];
            app.NumberofrawimagesLabel.Text = 'Number of raw images';

            % Create Number_of_raw_image
            app.Number_of_raw_image = uieditfield(app.ImagepreprocessingTab, 'numeric');
            app.Number_of_raw_image.Position = [316 141 100 22];
            app.Number_of_raw_image.Value = 120;

            % Create Name1EditFieldLabel
            app.Name1EditFieldLabel = uilabel(app.ImagepreprocessingTab);
            app.Name1EditFieldLabel.HorizontalAlignment = 'right';
            app.Name1EditFieldLabel.Position = [23 109 44 22];
            app.Name1EditFieldLabel.Text = 'Name1';

            % Create Name1
            app.Name1 = uieditfield(app.ImagepreprocessingTab, 'text');
            app.Name1.Position = [82 109 100 22];
            app.Name1.Value = '1-1-';

            % Create BufferpartcountEditFieldLabel
            app.BufferpartcountEditFieldLabel = uilabel(app.ImagepreprocessingTab);
            app.BufferpartcountEditFieldLabel.HorizontalAlignment = 'right';
            app.BufferpartcountEditFieldLabel.Position = [23 141 87 22];
            app.BufferpartcountEditFieldLabel.Text = 'Bufferpartcount';

            % Create Bufferpartcount
            app.Bufferpartcount = uieditfield(app.ImagepreprocessingTab, 'numeric');
            app.Bufferpartcount.Position = [125 141 26 22];
            app.Bufferpartcount.Value = 10;

            % Create Name2EditFieldLabel
            app.Name2EditFieldLabel = uilabel(app.ImagepreprocessingTab);
            app.Name2EditFieldLabel.HorizontalAlignment = 'right';
            app.Name2EditFieldLabel.Position = [206 109 44 22];
            app.Name2EditFieldLabel.Text = 'Name2';

            % Create Name2
            app.Name2 = uieditfield(app.ImagepreprocessingTab, 'text');
            app.Name2.Position = [265 109 100 22];
            app.Name2.Value = '4kv80%300ul';

            % Create SelectafolderButton
            app.SelectafolderButton = uibutton(app.ImagepreprocessingTab, 'push');
            app.SelectafolderButton.ButtonPushedFcn = createCallbackFcn(app, @SelectafolderButtonPushed, true);
            app.SelectafolderButton.Position = [21 48 100 22];
            app.SelectafolderButton.Text = 'Select a folder';

            % Create RunButton
            app.RunButton = uibutton(app.ImagepreprocessingTab, 'push');
            app.RunButton.ButtonPushedFcn = createCallbackFcn(app, @RunButtonPushed, true);
            app.RunButton.Position = [22 16 100 22];
            app.RunButton.Text = 'Run';

            % Create tab1_path_display
            app.tab1_path_display = uieditfield(app.ImagepreprocessingTab, 'text');
            app.tab1_path_display.Editable = 'off';
            app.tab1_path_display.Position = [130 48 164 22];

            % Create NumberofreplicateEditFieldLabel
            app.NumberofreplicateEditFieldLabel = uilabel(app.ImagepreprocessingTab);
            app.NumberofreplicateEditFieldLabel.HorizontalAlignment = 'right';
            app.NumberofreplicateEditFieldLabel.Position = [23 76 110 22];
            app.NumberofreplicateEditFieldLabel.Text = 'Number of replicate';

            % Create Numberofreplicate
            app.Numberofreplicate = uieditfield(app.ImagepreprocessingTab, 'numeric');
            app.Numberofreplicate.Position = [148 76 100 22];
            app.Numberofreplicate.Value = 10;

            % Create Image
            app.Image = uiimage(app.ImagepreprocessingTab);
            app.Image.Position = [344 2 100 100];
            app.Image.ImageSource = 'pulab.png';

            % Create OpticalflowanalysisquivermapTab
            app.OpticalflowanalysisquivermapTab = uitab(app.TabGroup);
            app.OpticalflowanalysisquivermapTab.Title = 'Optical flow analysis (quiver map)';

            % Create OFfolderbutton
            app.OFfolderbutton = uibutton(app.OpticalflowanalysisquivermapTab, 'push');
            app.OFfolderbutton.ButtonPushedFcn = createCallbackFcn(app, @OFfolderbuttonButtonPushed, true);
            app.OFfolderbutton.Position = [10 146 100 22];
            app.OFfolderbutton.Text = 'Select a folder';

            % Create OFfolderpath
            app.OFfolderpath = uieditfield(app.OpticalflowanalysisquivermapTab, 'text');
            app.OFfolderpath.Editable = 'off';
            app.OFfolderpath.Position = [121 147 233 20];

            % Create FirstframeforanalysisLabel
            app.FirstframeforanalysisLabel = uilabel(app.OpticalflowanalysisquivermapTab);
            app.FirstframeforanalysisLabel.HorizontalAlignment = 'right';
            app.FirstframeforanalysisLabel.Position = [4 114 127 22];
            app.FirstframeforanalysisLabel.Text = 'First frame for analysis';

            % Create First_frame_to_analyze
            app.First_frame_to_analyze = uieditfield(app.OpticalflowanalysisquivermapTab, 'numeric');
            app.First_frame_to_analyze.Position = [146 114 100 22];
            app.First_frame_to_analyze.Value = 1;

            % Create NumberofframeforanalysisEditFieldLabel
            app.NumberofframeforanalysisEditFieldLabel = uilabel(app.OpticalflowanalysisquivermapTab);
            app.NumberofframeforanalysisEditFieldLabel.HorizontalAlignment = 'right';
            app.NumberofframeforanalysisEditFieldLabel.Position = [5 48 159 22];
            app.NumberofframeforanalysisEditFieldLabel.Text = 'Number of frame for analysis';

            % Create NumberofframeforanalysisEditField
            app.NumberofframeforanalysisEditField = uieditfield(app.OpticalflowanalysisquivermapTab, 'numeric');
            app.NumberofframeforanalysisEditField.Position = [179 48 66 22];
            app.NumberofframeforanalysisEditField.Value = 1200;

            % Create RawvideoframerateLabel
            app.RawvideoframerateLabel = uilabel(app.OpticalflowanalysisquivermapTab);
            app.RawvideoframerateLabel.HorizontalAlignment = 'right';
            app.RawvideoframerateLabel.Position = [5 80 119 22];
            app.RawvideoframerateLabel.Text = 'Raw video frame rate';

            % Create Framerate_of_raw_video
            app.Framerate_of_raw_video = uieditfield(app.OpticalflowanalysisquivermapTab, 'numeric');
            app.Framerate_of_raw_video.Position = [139 80 107 22];
            app.Framerate_of_raw_video.Value = 4500;

            % Create RunButton_2
            app.RunButton_2 = uibutton(app.OpticalflowanalysisquivermapTab, 'push');
            app.RunButton_2.ButtonPushedFcn = createCallbackFcn(app, @RunButton_2Pushed, true);
            app.RunButton_2.Position = [17 16 100 22];
            app.RunButton_2.Text = 'Run';

            % Create ProcessingstatusLabel
            app.ProcessingstatusLabel = uilabel(app.OpticalflowanalysisquivermapTab);
            app.ProcessingstatusLabel.HorizontalAlignment = 'right';
            app.ProcessingstatusLabel.Position = [129 16 100 22];
            app.ProcessingstatusLabel.Text = 'Processing status';

            % Create processingstatus
            app.processingstatus = uieditfield(app.OpticalflowanalysisquivermapTab, 'text');
            app.processingstatus.HorizontalAlignment = 'center';
            app.processingstatus.Position = [244 16 57 22];
            app.processingstatus.Value = '0/0';

            % Create Image2
            app.Image2 = uiimage(app.OpticalflowanalysisquivermapTab);
            app.Image2.Position = [344 2 100 100];
            app.Image2.ImageSource = 'pulab.png';

            % Create OpticalflowanalysisheatmapTab
            app.OpticalflowanalysisheatmapTab = uitab(app.TabGroup);
            app.OpticalflowanalysisheatmapTab.Title = 'Optical flow analysis (heatmap)';

            % Create RunButton_3
            app.RunButton_3 = uibutton(app.OpticalflowanalysisheatmapTab, 'push');
            app.RunButton_3.ButtonPushedFcn = createCallbackFcn(app, @RunButton_3Pushed, true);
            app.RunButton_3.Position = [17 16 100 22];
            app.RunButton_3.Text = 'Run';

            % Create SelectavideoButton
            app.SelectavideoButton = uibutton(app.OpticalflowanalysisheatmapTab, 'push');
            app.SelectavideoButton.ButtonPushedFcn = createCallbackFcn(app, @SelectavideoButtonPushed, true);
            app.SelectavideoButton.Position = [10 155 100 22];
            app.SelectavideoButton.Text = 'Select a video';

            % Create colorpath
            app.colorpath = uieditfield(app.OpticalflowanalysisheatmapTab, 'text');
            app.colorpath.Position = [114 155 152 22];

            % Create filenameEditFieldLabel
            app.filenameEditFieldLabel = uilabel(app.OpticalflowanalysisheatmapTab);
            app.filenameEditFieldLabel.HorizontalAlignment = 'right';
            app.filenameEditFieldLabel.Position = [271 155 51 22];
            app.filenameEditFieldLabel.Text = 'filename';

            % Create filenameEditField
            app.filenameEditField = uieditfield(app.OpticalflowanalysisheatmapTab, 'text');
            app.filenameEditField.Position = [328 155 105 22];

            % Create FirstframeforanalysisLabel_2
            app.FirstframeforanalysisLabel_2 = uilabel(app.OpticalflowanalysisheatmapTab);
            app.FirstframeforanalysisLabel_2.HorizontalAlignment = 'right';
            app.FirstframeforanalysisLabel_2.Position = [4 124 127 22];
            app.FirstframeforanalysisLabel_2.Text = 'First frame for analysis';

            % Create Firstframetoanalyze_colormap
            app.Firstframetoanalyze_colormap = uieditfield(app.OpticalflowanalysisheatmapTab, 'numeric');
            app.Firstframetoanalyze_colormap.Position = [146 122 83 22];
            app.Firstframetoanalyze_colormap.Value = 480;

            % Create RawvideofarmerateEditFieldLabel
            app.RawvideofarmerateEditFieldLabel = uilabel(app.OpticalflowanalysisheatmapTab);
            app.RawvideofarmerateEditFieldLabel.HorizontalAlignment = 'right';
            app.RawvideofarmerateEditFieldLabel.Position = [10 91 119 22];
            app.RawvideofarmerateEditFieldLabel.Text = 'Raw video farme rate';

            % Create Rawvideofarmerate_colormap
            app.Rawvideofarmerate_colormap = uieditfield(app.OpticalflowanalysisheatmapTab, 'numeric');
            app.Rawvideofarmerate_colormap.Position = [144 90 85 22];
            app.Rawvideofarmerate_colormap.Value = 4500;

            % Create NumberofframeforanalysisLabel
            app.NumberofframeforanalysisLabel = uilabel(app.OpticalflowanalysisheatmapTab);
            app.NumberofframeforanalysisLabel.HorizontalAlignment = 'right';
            app.NumberofframeforanalysisLabel.Position = [5 56 159 22];
            app.NumberofframeforanalysisLabel.Text = 'Number of frame for analysis';

            % Create Numberofframetoanalyze_colormap
            app.Numberofframetoanalyze_colormap = uieditfield(app.OpticalflowanalysisheatmapTab, 'numeric');
            app.Numberofframetoanalyze_colormap.Position = [179 56 50 22];
            app.Numberofframetoanalyze_colormap.Value = 200;

            % Create Image2_2
            app.Image2_2 = uiimage(app.OpticalflowanalysisheatmapTab);
            app.Image2_2.Position = [344 2 100 100];
            app.Image2_2.ImageSource = 'pulab.png';

            % Create MeanvelocitycmsEditFieldLabel
            app.MeanvelocitycmsEditFieldLabel = uilabel(app.OpticalflowanalysisheatmapTab);
            app.MeanvelocitycmsEditFieldLabel.HorizontalAlignment = 'right';
            app.MeanvelocitycmsEditFieldLabel.Position = [125 16 114 22];
            app.MeanvelocitycmsEditFieldLabel.Text = 'Mean velocity cm / s';

            % Create Meanvelocitycms_colormap
            app.Meanvelocitycms_colormap = uieditfield(app.OpticalflowanalysisheatmapTab, 'numeric');
            app.Meanvelocitycms_colormap.Position = [254 16 60 22];

            % Create FlowpatterncharacterizationTab
            app.FlowpatterncharacterizationTab = uitab(app.TabGroup);
            app.FlowpatterncharacterizationTab.Title = 'Flow pattern characterization';

            % Create Image2_3
            app.Image2_3 = uiimage(app.FlowpatterncharacterizationTab);
            app.Image2_3.Position = [344 2 100 100];
            app.Image2_3.ImageSource = 'pulab.png';

            % Create SelectavideoButton_flow
            app.SelectavideoButton_flow = uibutton(app.FlowpatterncharacterizationTab, 'push');
            app.SelectavideoButton_flow.ButtonPushedFcn = createCallbackFcn(app, @SelectavideoButton_flowPushed, true);
            app.SelectavideoButton_flow.Position = [9 155 100 22];
            app.SelectavideoButton_flow.Text = 'Select a video';

            % Create path_flow
            app.path_flow = uieditfield(app.FlowpatterncharacterizationTab, 'text');
            app.path_flow.Position = [113 155 152 22];

            % Create filenameEditFieldLabel_flow
            app.filenameEditFieldLabel_flow = uilabel(app.FlowpatterncharacterizationTab);
            app.filenameEditFieldLabel_flow.HorizontalAlignment = 'right';
            app.filenameEditFieldLabel_flow.Position = [266 155 55 22];
            app.filenameEditFieldLabel_flow.Text = 'Filename';

            % Create filename_flow
            app.filename_flow = uieditfield(app.FlowpatterncharacterizationTab, 'text');
            app.filename_flow.Position = [327 155 105 22];

            % Create FirstframeforanalysisLabel_3
            app.FirstframeforanalysisLabel_3 = uilabel(app.FlowpatterncharacterizationTab);
            app.FirstframeforanalysisLabel_3.HorizontalAlignment = 'right';
            app.FirstframeforanalysisLabel_3.Position = [6 121 127 22];
            app.FirstframeforanalysisLabel_3.Text = 'First frame for analysis';

            % Create Firstframetoanalyze_flow
            app.Firstframetoanalyze_flow = uieditfield(app.FlowpatterncharacterizationTab, 'numeric');
            app.Firstframetoanalyze_flow.Position = [148 119 83 22];
            app.Firstframetoanalyze_flow.Value = 1;

            % Create NumberofframeforanalysisLabel_2
            app.NumberofframeforanalysisLabel_2 = uilabel(app.FlowpatterncharacterizationTab);
            app.NumberofframeforanalysisLabel_2.HorizontalAlignment = 'right';
            app.NumberofframeforanalysisLabel_2.Position = [6 86 159 22];
            app.NumberofframeforanalysisLabel_2.Text = 'Number of frame for analysis';

            % Create Numberofframetoanalyze_flow
            app.Numberofframetoanalyze_flow = uieditfield(app.FlowpatterncharacterizationTab, 'numeric');
            app.Numberofframetoanalyze_flow.Position = [180 86 50 22];
            app.Numberofframetoanalyze_flow.Value = 1200;

            % Create RunButton_4
            app.RunButton_4 = uibutton(app.FlowpatterncharacterizationTab, 'push');
            app.RunButton_4.ButtonPushedFcn = createCallbackFcn(app, @RunButton_4Pushed, true);
            app.RunButton_4.Position = [10 48 100 22];
            app.RunButton_4.Text = 'Run';

            % Create TimeratioofturbulentflowEditFieldLabel
            app.TimeratioofturbulentflowEditFieldLabel = uilabel(app.FlowpatterncharacterizationTab);
            app.TimeratioofturbulentflowEditFieldLabel.HorizontalAlignment = 'right';
            app.TimeratioofturbulentflowEditFieldLabel.Position = [6 16 147 22];
            app.TimeratioofturbulentflowEditFieldLabel.Text = 'Time ratio of turbulent flow';

            % Create Timeratioofturbulentflow_flow
            app.Timeratioofturbulentflow_flow = uieditfield(app.FlowpatterncharacterizationTab, 'numeric');
            app.Timeratioofturbulentflow_flow.Position = [168 16 67 22];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = schlieren_app

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