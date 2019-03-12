function [ebsd,G_Complete] = fragmentReconstruction(G_Complete,ebsd,grains)
%fragmentReconstruction comines fragments that appear are one twin but are
%broken up due to resolution issue. Fixes count stats.. 
angleDiffTol=3*degree;
twins2ConsiderMerging=G_Complete.Nodes.Id(G_Complete.Nodes.Type>0);
[omega,a_mag,b_min] = fitEllipse(grains);

    G_Complete.Nodes.MergeTwin = zeros(length(G_Complete.Nodes.Id),1,'logical');

    for i=1:max(G_Complete.Edges.Group) 
        egroupId = find((i==G_Complete.Edges.Group)==true); %converts logical arrays to indices
        ngroupId = find((i==G_Complete.Nodes.Group)==true);
        nFamily = G_Complete.Nodes.FamilyID(ngroupId);
        nType = G_Complete.Nodes.Type(ngroupId); 
        nId = G_Complete.Nodes.Id(ngroupId);
        eType = G_Complete.Edges.type(egroupId);
        eVote = G_Complete.Edges.Vote(egroupId,:);
        ePairs = G_Complete.Edges.pairs(egroupId,:);
        eFamily = G_Complete.Edges.FamilyID(egroupId,:);
        eGlobalId = G_Complete.Edges.GlobalID(egroupId);
        
        MergeTwin=zeros(length(nId),1,'logical');

        for j=1:length(nId)
            actFam=nFamily(j);
            if nType(j)>0
                for k=1:length(nId)
                   if k~=j && nFamily(k)==actFam
                      %Test if grains should be merged 
                      centroidj=grains(nId(j)).centroid;
                      centroidk=grains(nId(k)).centroid;
                      radiusSum=a_mag(nId(k))+a_mag(nId(j));
                      angleDiffEllipse=abs(omega(nId(k))-omega(nId(j)));
                      
                      %Construct a line and find min distance from other
                      %centroid
                      m = tan( omega(nId(j)));
                      b = centroidj(2) - (m * centroidj(1) );
                      B=-m;
                      C=-b;
                      A=1;
                      
                      distFromLine=abs(A*centroidk(2)+B*centroidk(1)+C)/sqrt(A^2+B^2);
                      
                      %Convert line to vector 
                      centroidDiff=norm(centroidk-centroidj);
                      

                      if  angleDiffEllipse<angleDiffTol && distFromLine<b_min(nId(j)) && centroidDiff<5*radiusSum
                            MergeTwin(j)=true;
                            MergeTwin(k)=true;
                            v=grains(nId(j)).centroid-grains(nId(k)).centroid;
                            vo=grains(nId(j)).centroid;
                            u=v/norm(v);
                            vp=[u(2),-u(1)]*2.5*b_min(nId(j));
                            polyRegion=[grains(nId(j)).centroid-vp/4;grains(nId(j)).centroid+vp/4;
                                grains(nId(k)).centroid+vp/4;grains(nId(k)).centroid-vp/4];
                            ebsd(ebsd.inpolygon(polyRegion)).orientations=grains(nId(j)).meanOrientation;
                            

                      end
                   end
                end
            end
            
        end
        G_Complete.Nodes.MergeTwin(nId)=MergeTwin
    if 1==0
            %visualize grain to debug             
            figure; 
            plot(grains(nId),...
                G_Complete.Nodes.FamilyID(nId),'Micronbar','off')
%                 grains(nId).meanOrientation,'Micronbar','off')
            hold on
            e2keep=(i==G_Complete.Edges.Group)==true;
            
%             Ggrain=rmedge(G_Complete,G_Complete.Edges.pairs(~e2keep,1),G_Complete.Edges.pairs(~e2keep,2));
            p=plot(G_Complete,'XData',G_Complete.Nodes.centroids(:,1),...
                'YData',G_Complete.Nodes.centroids(:,2),'displayName','graph');
            hold off
            p.Marker='s';p.NodeColor='k';p.MarkerSize=3;p.EdgeColor='k';
            labeledge(p,G_Complete.Edges.pairs(:,1),G_Complete.Edges.pairs(:,2),G_Complete.Edges.GlobalID);
            labelnode(p,G_Complete.Nodes.Id,G_Complete.Nodes.Id);
            ebsd2(ebsd2.inpolygon(polyRegion)).orientations=grains(402).meanOrientation;
        end
        
    end
% uc= ebsd2.unitCell 
% v=grains(402).centroid-grains(399).centroid;
% vo=grains(399).centroid
% u=v/norm(v);
% vp=[u(2),-u(1)]*xdist
% polyRegion=[grains(402).centroid-vp/4;grains(402).centroid+vp/4;
%     grains(399).centroid+vp/4;grains(399).centroid-vp/4]
% 
% % figure;plot(grains(402),grains(402).meanOrientation)
% 
% % figure;scatter(polyRegion(:,1),polyRegion(:,2))
% % rectangle('position',polyRegion,'edgecolor','r','linewidth',2)
% 
% %
% ebsd2(ebsd2.inpolygon(polyRegion)).orientations=grains(402).meanOrientation;
end

