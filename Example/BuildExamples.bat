@ECHO OFF
REM ����һ���� cfg/dof/dproj ��������Ϣ�н����赥Ԫ�����·����������·������������ֱ�Ӽ��빤���ļ��У�����ά���鷳��
CD VCL
CALL BuildVclExamples.bat
CD ..
CD FMX
CALL BuildFmxExamples.bat
CD ..
CD FPC
CALL BuildFpcExamples.bat
CD ..
ECHO Examples Build Complete.